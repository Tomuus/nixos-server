#!/usr/bin/env python3
"""F1 prediction game for friends: accounts, bets, scoring, txt exports. Standard library only."""
import hashlib, hmac, html, json, os, re, secrets, sqlite3, sys, threading, time, urllib.request
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

E = os.environ.get
DATA, WEB, PORT = E("F1_DATA", "./data"), E("F1_WEB", "."), int(E("F1_PORT", "8087"))
SEASON, API = E("F1_SEASON", "2026"), E("F1_API", "https://api.jolpi.ca/ergast/f1").rstrip("/")
NEWS = E("F1_NEWS", "https://www.motorsport.com/rss/f1/news/")
ADMINS = {x.strip().lower() for x in E("F1_ADMINS", "").split(",") if x.strip()}
LOCK_MIN, OPEN_MIN = int(E("F1_LOCK_MIN", "15")), int(E("F1_OPEN_AFTER_QUALI_MIN", "-1"))
COOKIE_FLAGS = "HttpOnly; SameSite=Lax; Path=/; Max-Age=7776000" + ("" if E("F1_DEV") else "; Secure")
try:
    INVITE = open(E("F1_INVITE_FILE") or os.path.join(E("CREDENTIALS_DIRECTORY", ""), "invite")).read().strip()
except OSError:
    INVITE = ""                                     # no invite code -> registration disabled
DRIVERS = "VER ANT HAM LEC HAD PIA LAW ALO NOR LIN HUL STR COL BEA OCO GAS SAI BOR PER RUS ALB BOT".split()
N = len(DRIVERS)
CSP = ("default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src 'self' data:; "
       "connect-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'")

os.makedirs(DATA, exist_ok=True)
L = threading.RLock()
db = sqlite3.connect(os.path.join(DATA, "f1.db"), check_same_thread=False)
db.execute("PRAGMA journal_mode=WAL")
for s in ("users(id INTEGER PRIMARY KEY, name TEXT UNIQUE COLLATE NOCASE, salt BLOB, pw BLOB)",
          "sessions(h TEXT PRIMARY KEY, uid INT, exp REAL)",
          "bets(uid INT, rnd INT, ord TEXT, ts REAL, PRIMARY KEY(uid, rnd))",
          "races(rnd INT PRIMARY KEY, name TEXT, race REAL, quali REAL)",
          "results(rnd INT PRIMARY KEY, ord TEXT, manual INT, ts REAL)",
          "kv(k TEXT PRIMARY KEY, v TEXT, ts REAL)"):
    db.execute("CREATE TABLE IF NOT EXISTS " + s)
db.commit()


def q(sql, a=()):
    with L:
        return db.execute(sql, a).fetchall()


def x(sql, a=()):
    with L:
        db.execute(sql, a)
        db.commit()


def kvset(k, v):
    x("INSERT INTO kv VALUES(?,?,?) ON CONFLICT(k) DO UPDATE SET v=?, ts=?", (k, v, time.time(), v, time.time()))


def kvget(k):
    r = q("SELECT v, ts FROM kv WHERE k=?", (k,))
    return (r[0][0], r[0][1]) if r else (None, 0)


# ---------- scoring ----------
def positions(order):
    pos = {c: i + 1 for i, c in enumerate(order)}
    n = len(order)
    for c in DRIVERS:                               # drivers missing from the classification go last
        if c not in pos:
            n += 1
            pos[c] = n
    return pos


def score(bet, result):
    pos = positions(result)
    return sum(max(0, N - abs(pos.get(c, N) - i)) for i, c in enumerate(bet, 1))


def window(r):                                      # r = (rnd, name, race, quali)
    return ((r[3] + OPEN_MIN * 60) if r[3] and OPEN_MIN >= 0 else 0), r[2] - LOCK_MIN * 60


def results():
    return {r[0]: r[1].split(",") for r in q("SELECT rnd, ord FROM results")}


def board(upto=None):
    res = {k: v for k, v in results().items() if upto is None or k <= upto}
    bets = {}
    for uid, rnd, o in q("SELECT uid, rnd, ord FROM bets"):
        bets[(uid, rnd)] = o.split(",")
    rows = []
    for uid, name in q("SELECT id, name FROM users"):
        pts = {r: (score(bets[(uid, r)], res[r]) if (uid, r) in bets else 0) for r in res}
        rows.append({"name": name, "pts": pts, "total": sum(pts.values())})
    rows.sort(key=lambda r: (-r["total"], r["name"].lower()))
    return sorted(res), rows


# ---------- txt exports ----------
def slug(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")


def export(rnd):
    r = q("SELECT * FROM races WHERE rnd=?", (rnd,))
    res = results().get(rnd)
    if not r or not res:
        return
    d = os.path.join(DATA, "exports", f"round-{rnd:02d}-{slug(r[0][1])}")
    os.makedirs(d, exist_ok=True)
    head = f"Round {rnd} - {r[0][1]} ({SEASON})\n"
    open(os.path.join(d, "result.txt"), "w").write(head + "Official result\n" + "".join(f"{i}{c}\n" for i, c in enumerate(res, 1)))
    users = {u: n for u, n in q("SELECT id, name FROM users")}
    out = head + "Bets\n"
    for uid, o in q("SELECT uid, ord FROM bets WHERE rnd=? ORDER BY uid", (rnd,)):
        out += f"\n== {users.get(uid, '?')} == ({score(o.split(','), res)} pts)\n" + "".join(f"{i}{c}\n" for i, c in enumerate(o.split(","), 1))
    open(os.path.join(d, "bets.txt"), "w").write(out)
    rounds, rows = board(rnd)
    w = max([len(u["name"]) for u in rows] + [4])
    t = head + "\nPoints this round\n" + "".join(f"{i:>2}. {u['name']:<{w}} {u['pts'][rnd]}\n" for i, u in enumerate(sorted(rows, key=lambda u: -u["pts"][rnd]), 1))
    t += f"\nSeason standings after round {rnd}\n" + "".join(f"{i:>2}. {u['name']:<{w}} {u['total']}\n" for i, u in enumerate(rows, 1))
    open(os.path.join(d, "points.txt"), "w").write(t)


def export_all():
    for rnd in results():
        export(rnd)


# ---------- data from the Jolpica (Ergast) API ----------
def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "f1-friends-game/1.0"})
    with urllib.request.urlopen(req, timeout=10) as f:
        return f.read(2_000_000)


def ts(d, t):
    return datetime.strptime(f"{d} {(t or '13:00:00Z').rstrip('Z')[:8]}", "%Y-%m-%d %H:%M:%S").replace(tzinfo=timezone.utc).timestamp()


def sync_schedule():
    for r in json.loads(fetch(f"{API}/{SEASON}.json?limit=100"))["MRData"]["RaceTable"]["Races"]:
        qd = r.get("Qualifying")
        a = (int(r["round"]), r["raceName"], ts(r["date"], r.get("time")), ts(qd["date"], qd.get("time")) if qd else None)
        x("INSERT INTO races VALUES(?,?,?,?) ON CONFLICT(rnd) DO UPDATE SET name=?, race=?, quali=?", a + a[1:])


def code(d):
    return d.get("code") or d["familyName"][:3].upper()


def check(rs, rnd):
    """The API race must be exactly the round (season, number, date) we asked for - otherwise it is ignored."""
    if not rs:
        return None
    r, row = rs[0], q("SELECT race FROM races WHERE rnd=?", (rnd,))
    want = datetime.fromtimestamp(row[0][0], timezone.utc).strftime("%Y-%m-%d") if row else None
    if str(r.get("season")) != SEASON or str(r.get("round")) != str(rnd) or r.get("date") != want:
        print(f"api mismatch for round {rnd}: got season {r.get('season')} round {r.get('round')} "
              f"{r.get('raceName')} {r.get('date')}, expected {want} - ignored", file=sys.stderr)
        return None
    kvset(f"info{rnd}", json.dumps({"name": r.get("raceName", ""), "date": r["date"]}))
    return r


def sync_result(rnd):
    race = check(json.loads(fetch(f"{API}/{SEASON}/{rnd}/results.json?limit=100"))["MRData"]["RaceTable"]["Races"], rnd)
    if not race or len(race.get("Results", [])) < 10:
        return
    order = [code(r["Driver"]) for r in sorted(race["Results"], key=lambda r: int(r["position"]))]
    old = q("SELECT ord, manual FROM results WHERE rnd=?", (rnd,))
    if old and old[0][1]:
        return                                       # admin override wins
    if not old or old[0][0] != ",".join(order):
        x("INSERT INTO results VALUES(?,?,0,?) ON CONFLICT(rnd) DO UPDATE SET ord=?, ts=?",
          (rnd, ",".join(order), time.time(), ",".join(order), time.time()))
        export_all()                                 # later standings depend on this round too
        print(f"result for round {rnd} updated", file=sys.stderr)


def sync_quali(rnd):
    race = check(json.loads(fetch(f"{API}/{SEASON}/{rnd}/qualifying.json?limit=100"))["MRData"]["RaceTable"]["Races"], rnd)
    rows = [{"p": int(r["position"]), "c": code(r["Driver"]), "t": r.get("Q3") or r.get("Q2") or r.get("Q1") or ""}
            for r in (race.get("QualifyingResults", []) if race else [])]
    if rows:
        kvset(f"quali{rnd}", json.dumps(rows))


def sync_news():
    xml = fetch(NEWS).decode("utf-8", "replace")
    items = []
    for it in re.findall(r"<item>(.*?)</item>", xml, re.S)[:10]:
        t = re.search(r"<title>(.*?)</title>", it, re.S)
        l = re.search(r"<link>(.*?)</link>", it, re.S)
        if t and l:
            clean = lambda s: html.unescape(re.sub(r"<!\[CDATA\[|\]\]>", "", s)).strip()
            items.append({"t": clean(t.group(1))[:200], "l": clean(l.group(1))})
    if items:
        kvset("news", json.dumps(items))


def wipe():                                          # forget downloaded results/qualifying (admin overrides stay)
    x("DELETE FROM results WHERE manual=0")
    x("DELETE FROM kv WHERE k LIKE 'res%' OR k LIKE 'quali%' OR k LIKE 'qf%' OR k LIKE 'info%' OR k LIKE 'sched%'")


def migrate():
    if kvget("v")[0] != "2":
        wipe()
        kvset("v", "2")


def worker():
    while True:
        now = time.time()
        if now - kvget("sched")[1] > 6 * 3600 and now - kvget("schedtry")[1] > 600:
            kvset("schedtry", "1")
            try:
                sync_schedule(); kvset("sched", "1")
            except Exception as e:
                print("schedule:", e, file=sys.stderr)
        for rnd, _, race, quali in q("SELECT * FROM races ORDER BY rnd"):
            since, have = now - race, bool(q("SELECT 1 FROM results WHERE rnd=?", (rnd,)))
            if since > 3 * 3600:                     # race is over: fetch its result, and re-check for penalties
                every = (1800 if since < 3 * 86400 else 86400) if not have else 1800 if since < 86400 else 6 * 3600 if since < 14 * 86400 else None
                if every and now - kvget(f"res{rnd}")[1] > every:
                    try:
                        sync_result(rnd)
                    except Exception as e:
                        print("result:", rnd, e, file=sys.stderr)
                    kvset(f"res{rnd}", "1")
                    time.sleep(0.5)
            if quali and now - quali > 4500:         # qualifying is over
                got = kvget(f"quali{rnd}")[0] is not None
                every = (3600 if now - quali < 2 * 86400 else None) if got else (1800 if now - quali < 3 * 86400 else 86400)
                if every and now - kvget(f"qf{rnd}")[1] > every:
                    try:
                        sync_quali(rnd)
                    except Exception as e:
                        print("quali:", rnd, e, file=sys.stderr)
                    kvset(f"qf{rnd}", "1")
                    time.sleep(0.5)
        if now - kvget("newsfetch")[1] > 900:
            try:
                sync_news()
            except Exception as e:
                print("news:", e, file=sys.stderr)
            kvset("newsfetch", "1")
        time.sleep(20)


# ---------- accounts ----------
NAME = re.compile(r"[\w\- ]{3,20}")
fails, hits = {}, {}


def limited(key, bucket, limit, window_s=600):
    now = time.time()
    with L:
        h = [t for t in bucket.get(key, []) if now - t < window_s] + [now]
        bucket[key] = h
        if len(bucket) > 5000:
            bucket.clear()
        return len(h) > limit


def nfails(key):
    now = time.time()
    return len([t for t in fails.get(key, []) if now - t < 600])


def hpw(pw, salt):
    return hashlib.scrypt(pw.encode(), salt=salt, n=2 ** 14, r=8, p=1, dklen=32)


def new_session(uid):
    tok = secrets.token_urlsafe(32)
    x("INSERT INTO sessions VALUES(?,?,?)", (hashlib.sha256(tok.encode()).hexdigest(), uid, time.time() + 90 * 86400))
    x("DELETE FROM sessions WHERE exp<?", (time.time(),))
    return tok


class H(BaseHTTPRequestHandler):
    timeout = 10
    server_version, sys_version = "f1", ""

    def log_message(self, *a):
        pass

    def ip(self):
        return (self.headers.get("CF-Connecting-IP") or self.client_address[0])[:64]

    def out(self, code, body, ctype="application/json", extra=None):
        b = body if isinstance(body, bytes) else json.dumps(body, ensure_ascii=False).encode()
        self.send_response(code)
        for k, v in {"Content-Type": ctype, "Content-Length": str(len(b)), "X-Content-Type-Options": "nosniff",
                     "Referrer-Policy": "no-referrer", "X-Robots-Tag": "noindex, nofollow", "Cache-Control": "no-store",
                     **(extra or {})}.items():
            self.send_header(k, v)
        if ctype.startswith("text/html"):
            self.send_header("Content-Security-Policy", CSP)
        self.end_headers()
        self.wfile.write(b)

    def err(self, code, msg):
        self.out(code, {"error": msg})

    def user(self):
        m = re.search(r"(?:^|; )sid=([\w-]+)", self.headers.get("Cookie", ""))
        if not m:
            return None
        r = q("SELECT u.id, u.name FROM sessions s JOIN users u ON u.id=s.uid WHERE s.h=? AND s.exp>?",
              (hashlib.sha256(m.group(1).encode()).hexdigest(), time.time()))
        return (r[0][0], r[0][1]) if r else None

    def body(self):
        try:
            n = int(self.headers.get("Content-Length", ""))
            if 0 < n <= 4096:
                d = json.loads(self.rfile.read(n))
                return d if isinstance(d, dict) else None
        except (ValueError, TypeError):
            pass
        return None

    def do_GET(self):
        self.route("GET")

    def do_POST(self):
        self.route("POST")

    def do_PUT(self):
        self.route("PUT")

    def do_DELETE(self):
        self.route("DELETE")

    def route(self, m):
        p = self.path.split("?")[0]
        if m == "GET" and p in ("/", "/index.html"):
            try:
                return self.out(200, open(os.path.join(WEB, "index.html"), "rb").read(), "text/html; charset=utf-8")
            except OSError:
                return self.err(404, "no page")
        if p == "/robots.txt":
            return self.out(200, b"User-agent: *\nDisallow: /\n", "text/plain")
        if not p.startswith("/api/"):
            return self.err(404, "not found")
        if m != "GET" and self.headers.get("X-Req") != "1":
            return self.err(403, "bad request")
        if limited(self.ip(), hits, 300, 60):
            return self.err(429, "Too many requests")
        try:
            self.api(m, p[5:])
        except Exception as e:
            print("error:", p, repr(e), file=sys.stderr)
            self.err(500, "server error")

    def api(self, m, p):
        if m == "POST" and p in ("register", "login"):
            return self.auth(p)
        u = self.user()
        if p == "state":
            return self.state(u)
        if not u:
            return self.err(401, "login required")
        admin = u[1].lower() in ADMINS
        mm = re.fullmatch(r"(bet|round|admin/result|export)/(\d+)(?:/(bets|result|points)\.txt)?", p)
        rnd = int(mm.group(2)) if mm else 0
        race = q("SELECT * FROM races WHERE rnd=?", (rnd,)) if mm else []
        if m == "POST" and p == "logout":
            x("DELETE FROM sessions WHERE uid=?", (u[0],))
            return self.out(200, {"ok": True}, extra={"Set-Cookie": "sid=; Max-Age=0; Path=/"})
        if m == "GET" and p == "leaderboard":
            rounds, rows = board()
            return self.out(200, {"rounds": rounds, "rows": rows})
        if m == "GET" and p == "side":
            done = [r for r in q("SELECT rnd, name FROM races WHERE quali IS NOT NULL AND quali<? ORDER BY rnd", (time.time(),))]
            ql = json.loads(kvget(f"quali{done[-1][0]}")[0] or "[]") if done else []
            return self.out(200, {"quali": {"name": done[-1][1] if done else "", "rows": ql}, "news": json.loads(kvget("news")[0] or "[]")})
        if p == "admin/refresh" and m == "POST":
            if not admin:
                return self.err(403, "admin only")
            wipe()
            return self.out(200, {"ok": True})
        if not mm or not race:
            return self.err(404, "not found")
        op, cl = window(race[0])
        now = time.time()
        if mm.group(1) == "bet":
            if m == "GET":
                b = q("SELECT ord FROM bets WHERE uid=? AND rnd=?", (u[0], rnd))
                return self.out(200, {"order": b[0][0].split(",") if b else None})
            d = self.body()
            o = d.get("order") if d else None
            if m != "PUT" or not isinstance(o, list) or sorted(map(str, o)) != sorted(DRIVERS):
                return self.err(400, "Invalid order")
            if now < op:
                return self.err(403, "Betting is not open yet")
            if now >= cl:
                return self.err(403, "Betting is closed")
            x("INSERT INTO bets VALUES(?,?,?,?) ON CONFLICT(uid,rnd) DO UPDATE SET ord=?, ts=?",
              (u[0], rnd, ",".join(o), now, ",".join(o), now))
            return self.out(200, {"ok": True})
        if mm.group(1) == "round" and m == "GET":
            res = results().get(rnd)
            out = {"rnd": rnd, "name": race[0][1], "result": res, "locked": now >= cl, "bets": [],
                   "quali": json.loads(kvget(f"quali{rnd}")[0] or "null"), "info": json.loads(kvget(f"info{rnd}")[0] or "null")}
            if now >= cl:                           # other people's bets stay hidden until betting closes
                users = dict(q("SELECT id, name FROM users"))
                out["bets"] = [{"name": users.get(uid, "?"), "order": o.split(","), "pts": score(o.split(","), res) if res else None}
                               for uid, o in q("SELECT uid, ord FROM bets WHERE rnd=? ORDER BY uid", (rnd,))]
            return self.out(200, out)
        if mm.group(1) == "export" and m == "GET" and mm.group(3):
            f = os.path.join(DATA, "exports", f"round-{rnd:02d}-{slug(race[0][1])}", mm.group(3) + ".txt")
            try:
                return self.out(200, open(f, "rb").read(), "text/plain; charset=utf-8")
            except OSError:
                return self.err(404, "not available yet")
        if mm.group(1) == "admin/result":
            if not admin:
                return self.err(403, "admin only")
            if m == "DELETE":
                x("UPDATE results SET manual=0 WHERE rnd=?", (rnd,))
                x("DELETE FROM kv WHERE k=?", (f"res{rnd}",))
                return self.out(200, {"ok": True})
            d = self.body()
            o = d.get("order") if d else None
            if m != "POST" or not isinstance(o, list) or not 10 <= len(o) <= 30 or len(set(o)) != len(o) \
                    or not all(isinstance(c, str) and re.fullmatch(r"[A-Z]{3}", c) for c in o):
                return self.err(400, "Invalid result")
            x("INSERT INTO results VALUES(?,?,1,?) ON CONFLICT(rnd) DO UPDATE SET ord=?, manual=1, ts=?",
              (rnd, ",".join(o), now, ",".join(o), now))
            export_all()
            return self.out(200, {"ok": True})
        self.err(404, "not found")

    def state(self, u):
        base = {"user": u[1] if u else None, "admin": bool(u and u[1].lower() in ADMINS), "now": time.time(),
                "drivers": DRIVERS, "season": SEASON, "invite": bool(INVITE)}
        if u:
            res = results()
            base["rounds"] = [{"rnd": r[0], "name": r[1], "race": r[2], "open": window(r)[0], "close": window(r)[1],
                               "quali": r[3], "result": r[0] in res} for r in q("SELECT * FROM races ORDER BY rnd")]
            base["last"] = res[max(res)] if res else None
        self.out(200, base)

    def auth(self, kind):
        d = self.body() or {}
        name = " ".join(str(d.get("name", "")).split())
        pw = str(d.get("password", ""))
        if nfails(self.ip()) >= 20 or (kind == "login" and nfails(name.lower()) >= 8):
            return self.err(429, "Too many failed attempts, try again later")
        if kind == "register":
            if not INVITE or not hmac.compare_digest(INVITE.encode(), str(d.get("invite", "")).encode()):
                limited(self.ip(), fails, 999)
                return self.err(403, "Wrong invite code")
            if not NAME.fullmatch(name) or not 8 <= len(pw) <= 128:
                return self.err(400, "Name: 3-20 letters/digits; password: 8+ characters")
            salt = secrets.token_bytes(16)
            try:
                x("INSERT INTO users(name, salt, pw) VALUES(?,?,?)", (name, salt, hpw(pw, salt)))
            except sqlite3.IntegrityError:
                return self.err(409, "That name is taken")
            uid = q("SELECT id FROM users WHERE name=?", (name,))[0][0]
        else:
            r = q("SELECT id, salt, pw FROM users WHERE name=?", (name,))
            ok = bool(r) and hmac.compare_digest(r[0][2], hpw(pw[:128], r[0][1]))
            if not ok:
                limited(name.lower(), fails, 999)
                limited(self.ip(), fails, 999)
                return self.err(401, "Wrong name or password")
            uid = r[0][0]
        self.out(200, {"ok": True}, extra={"Set-Cookie": f"sid={new_session(uid)}; {COOKIE_FLAGS}"})


if __name__ == "__main__":
    migrate()
    export_all()
    threading.Thread(target=worker, daemon=True).start()
    ThreadingHTTPServer(("127.0.0.1", PORT), H).serve_forever()
