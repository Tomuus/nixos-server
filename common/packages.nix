{ pkgs, unstbl, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    htop
		lm_sensors
		cowsay
		fastfetch
		tree
  ];
}
