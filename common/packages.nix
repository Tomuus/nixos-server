{ pkgs, unstbl, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    htop
  ];
}
