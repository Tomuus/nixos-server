{ pkgs, unstbl, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    htop
    lm_sensors
    cowsay
    fastfetch
    tree
    steam-run
    ethtool
    p7zip
    imagemagick
    spatialite-tools
    unzip
    xorg.xrandr
    xorg.xvfb
    xauth
    x11vnc
  ];
}
