{ pkgs, ... }:

{
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  
  users.motdFile = "/etc/motd";

  time.timeZone = "Europe/Warsaw";

  system.stateVersion = "25.05";
}
