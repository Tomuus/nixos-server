{ pkgs, unstbl, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    htop
    lm_sensors
    cowsay
    nvim
    fastfetch
    tree
    ethtool
  ];
}
