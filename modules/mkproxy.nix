{ pkgs, ... }:
let
  mkproxy = pkgs.writeShellScriptBin "mkproxy" ''
    set -eu
    [ $# -eq 1 ] || { echo "usage: mkproxy <folder under MATERIALY>"; exit 1; }
    root=/shares/megaraid/projekty/MATERIALY
    src="$(realpath "$1")"
    case "$src" in "$root"/*) ;; *) echo "folder must be inside $root"; exit 1;; esac
    out=/shares/fast/proxies/"''${src#$root/}"

    exec 9>/run/mkproxy.lock
    flock -n 9 || { echo "mkproxy already running"; exit 0; }

    find "$src" -type f \( -iname '*.mov' -o -iname '*.mp4' \) ! -name '._*' -mmin +30 | while read -r f; do
      rel="''${f#$src/}"
      o="$out/''${rel%.*}.mov"
      [ -e "$o" ] && continue
      mkdir -p "$(dirname "$o")"
      echo "==> $f"
      nice -n 19 ffmpeg -nostdin -y -hide_banner -loglevel error -stats -hwaccel cuda -i "$f" \
        -map 0:v:0 -map 0:a? -map_metadata 0 \
        -vf scale=1920:-2 -c:v hevc_nvenc -profile:v main10 -pix_fmt p010le -tag:v hvc1 \
        -b:v 10M -c:a aac -b:a 192k -f mov "$o.part" && mv "$o.part" "$o"
    done
    if [ -d "$out" ]; then chown -R 1002:991 "$out" 2>/dev/null || true; fi
  '';
in
{
  environment.systemPackages = [ pkgs.ffmpeg-full pkgs.rsync pkgs.tmux mkproxy ];

  systemd.services.mkproxy-nightly = {
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    path = [ pkgs.ffmpeg-full pkgs.findutils pkgs.coreutils pkgs.util-linux ];
    environment.LD_LIBRARY_PATH = "/run/opengl-driver/lib";
    script = "${mkproxy}/bin/mkproxy /shares/megaraid/projekty/MATERIALY/Video";
  };

  systemd.timers.mkproxy-nightly = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "00:10";
      Persistent = true;
    };
  };
}
