{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.ffmpeg-full
    pkgs.rsync
    pkgs.tmux
    (pkgs.writeShellScriptBin "mkproxy" ''
      set -eu
      [ $# -eq 1 ] || { echo "usage: mkproxy <folder under MATERIALY>"; exit 1; }
      root=/shares/megaraid/projekty/MATERIALY
      src="$(realpath "$1")"
      case "$src" in "$root"/*) ;; *) echo "folder must be inside $root"; exit 1;; esac
      out=/shares/fast/proxies/"''${src#$root/}"
      mkdir -p "$out"
      find "$src" -type f \( -iname '*.mov' -o -iname '*.mp4' \) | while read -r f; do
        o="$out/$(basename "''${f%.*}").mov"
        [ -e "$o" ] && continue
        echo "==> $f"
        ffmpeg -nostdin -y -i "$f" -map 0:v:0 -map 0:a? -map_metadata 0 \
          -vf scale=1920:-2 -c:v hevc_nvenc -profile:v main10 -pix_fmt p010le \
          -c:v hevc_nvenc -profile:v main10 -pix_fmt p010le -tag:v hvc1 \
          -b:v 10M -c:a aac -b:a 192k -f mov "$o.part" && mv "$o.part" "$o"
      done
      chown -R 1002:991 "$out" 2>/dev/null || true
    '')
  ];
}
