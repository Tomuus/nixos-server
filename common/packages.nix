{ pkgs,... }:

{
  environment.systemPackages = with pkgs; [
    git
    htop
    lm_sensors
    cowsay
    fastfetch
    fluxbox
    tree
    ethtool
    p7zip
    unzip
  ];
}
