{ pkgs, unstbl, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    htop
    lm_sensors
    cowsay
    fastfetch
    tree
    ethtool
    p7zip
    imagemagick
    spatialite-tools
    unzip
    xorg.xvfb
  ];
}
