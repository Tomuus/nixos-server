#!/usr/bin/env python3
"""SPL quiz: serves the static page and a weekly leaderboard. Standard library only."""
import hashlib, hmac, json, os, re, sqlite3, threading, time
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

WEB = os.environ.get("SPL_WEB", "/var/www/spl")
DB = os.environ.get("SPL_DB", "board.db")
PORT = int(os.environ.get("SPL_PORT", "8086"))
NAME = re.compile(r"[\w\- ]{3,16}")
TOKEN = re.compile(r"[0-9a-f]{64}")
MAX_BODY, BATCH, WEEK_CAP, MAX_ROWS = 512, 50, 20000, 5000
BUCKET, REFILL, IP_LIMIT = 60.0, 1.0, 120          # answers burst / per second, requests per IP per minute
HTML = ("index.html", "text/html; charset=utf-8")
FILES = {"/": HTML, "/index.html": HTML}
IMG = re.compile(r"/([A-Za-z0-9][A-Za-z0-9._-]{0,60}\.(png|ico|jpg|webp))")   # icons/images only, no subfolders
TYPES = {"png": "image/png", "ico": "image/x-icon", "jpg": "image/jpeg", "webp": "image/webp"}
CSP = ("default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src 'self'; "
       "connect-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'")

lock = threading.Lock()
buckets, hits, cache = {}, {}, {"t": 0.0, "w": "", "rows": []}
db = sqlite3.connect(DB, check_same_thread=False)
db.execute("PRAGMA journal_mode=WAL")
db.execute("CREATE TABLE IF NOT EXISTS s(week TEXT, name TEXT COLLATE NOCASE, tok TEXT, "
           "c INT, t INT, last REAL, PRIMARY KEY(week, name))")


def week():
    y, w, _ = datetime.now(timezone.utc).isocalendar()
    return f"{y}-W{w:02d}"


def limited(ip):
    now = time.time()
    with lock:
        h = [x for x in hits.get(ip, []) if now - x < 60]
        h.append(now)
        hits[ip] = h
        if len(hits) > 5000:
            hits.clear()
        return len(h) > IP_LIMIT


def take(name, n):                                   # call with lock held
    now, k = time.time(), name.lower()
    tokens, last = buckets.get(k, (BUCKET, now))
    tokens = min(BUCKET, tokens + (now - last) * REFILL)
    ok = n <= tokens
    buckets[k] = (tokens - n if ok else tokens, now)
    if len(buckets) > 5000:
        buckets.clear()
    return ok


def store(name, th, c, t):
    w = week()
    with lock:
        row = db.execute("SELECT tok,t FROM s WHERE week=? AND name=?", (w, name)).fetchone()
        if row and not hmac.compare_digest(row[0], th):
            return 403, "Ten nick jest zajęty – wybierz inny."
        if not row and db.execute("SELECT COUNT(*) FROM s WHERE week=?", (w,)).fetchone()[0] >= MAX_ROWS:
            return 503, "Ranking jest chwilowo pełny."
        if (row[1] if row else 0) + t > WEEK_CAP:
            return 429, "Limit odpowiedzi na tydzień osiągnięty."
        if not take(name, t):
            return 429, "Odpowiadasz zbyt szybko."
        now = time.time()
        if row:
            db.execute("UPDATE s SET c=c+?, t=t+?, last=CASE WHEN ?>0 THEN ? ELSE last END "
                       "WHERE week=? AND name=?", (c, t, c, now, w, name))
        else:
            db.execute("INSERT INTO s VALUES(?,?,?,?,?,?)", (w, name, th, c, t, now if c else 0))
        db.commit()
        cache["t"] = 0.0
    return 200, "ok"


def board():
    now = time.time()
    with lock:
        if now - cache["t"] > 5 or cache["w"] != week():
            cache["w"] = week()
            cache["rows"] = [{"name": n, "correct": c, "total": t} for n, c, t in db.execute(
                "SELECT name,c,t FROM s WHERE week=? AND c>0 ORDER BY c DESC, last ASC LIMIT 20", (cache["w"],))]
            cache["t"] = now
        return {"week": cache["w"], "rows": cache["rows"]}


class H(BaseHTTPRequestHandler):
    timeout = 10
    server_version, sys_version = "spl", ""

    def log_message(self, *a):
        pass

    def ip(self):
        return (self.headers.get("CF-Connecting-IP") or self.client_address[0])[:64]

    def reply(self, code, body, ctype, extra=None):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "no-referrer")
        if ctype.startswith("text/html"):
            self.send_header("Content-Security-Policy", CSP)
        for k, v in (extra or {}).items():
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(body)

    def json(self, code, obj):
        self.reply(code, json.dumps(obj, ensure_ascii=False).encode(), "application/json",
                   {"Cache-Control": "no-store"})

    def do_GET(self):
        path = self.path.split("?")[0]
        if path == "/api/board":
            return self.json(429, {"error": "limit"}) if limited(self.ip()) else self.json(200, board())
        m = IMG.fullmatch(path)
        if path in FILES:
            name, ctype = FILES[path]
        elif m:
            name, ctype = m.group(1), TYPES[m.group(2)]
        else:
            return self.reply(404, b"not found", "text/plain")
        try:
            p = os.path.join(WEB, name)
            st = os.stat(p)
            etag = '"%x-%x"' % (st.st_mtime_ns, st.st_size)
            if self.headers.get("If-None-Match") == etag:
                return self.reply(304, b"", ctype, {"ETag": etag})
            with open(p, "rb") as f:
                body = f.read()
        except OSError:
            return self.reply(404, b"not found", "text/plain")
        cc = "no-cache" if name.endswith(".html") else "public, max-age=86400"
        self.reply(200, body, ctype, {"ETag": etag, "Cache-Control": cc})

    def do_POST(self):
        if self.path.split("?")[0] != "/api/score":
            return self.json(404, {"error": "not found"})
        if limited(self.ip()):
            return self.json(429, {"error": "Za dużo żądań – spróbuj za chwilę."})
        try:
            n = int(self.headers.get("Content-Length", ""))
        except ValueError:
            return self.json(411, {"error": "bad request"})
        if not 0 < n <= MAX_BODY:
            return self.json(413, {"error": "bad request"})
        try:
            d = json.loads(self.rfile.read(n))
            name = " ".join(str(d["name"]).split())
            tok, c, t = str(d["token"]), d["correct"], d["total"]
        except (ValueError, KeyError, TypeError):
            return self.json(400, {"error": "bad request"})
        if not (NAME.fullmatch(name) and TOKEN.fullmatch(tok)):
            return self.json(400, {"error": "Nieprawidłowy nick (3–16 znaków: litery, cyfry, spacja, _ lub -)."})
        if type(c) is not int or type(t) is not int or not 0 <= c <= t <= BATCH or t < 1:
            return self.json(400, {"error": "bad request"})
        code, msg = store(name, hashlib.sha256(tok.encode()).hexdigest(), c, t)
        self.json(code, {"ok": True} if code == 200 else {"error": msg})


if __name__ == "__main__":
    ThreadingHTTPServer(("127.0.0.1", PORT), H).serve_forever()
