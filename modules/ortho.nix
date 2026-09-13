{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    steam-run
    imagemagick
    spatialite-tools
    xrandr
    xvfb
    xauth
    x11vnc
  ];

  programs.bash.interactiveShellInit = ''
    o4xp() {
      export TERM=xterm
        tmux kill-session -t ortho4xp-gui 2>/dev/null
        pkill -f "Xvfb :1" 2>/dev/null
        sleep 1

        tmux new-session -d -s ortho4xp-gui \
        'Xvfb :1 -screen 0 1920x1080x24 & sleep 1; DISPLAY=:1 fluxbox & sleep 1; DISPLAY=:1 x11vnc -display :1 -forever -shared -localhost -passwd ortho4xp -xrandr & sleep 1; cd /var/lib/ortho4xp-bundled && DISPLAY=:1 steam-run ./Ortho4XP'       
        echo "ortho4xp-gui session started. Attach with: tmux attach -t ortho4xp-gui"
    }
  '';

}
