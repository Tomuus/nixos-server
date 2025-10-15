{ pkgs, ... }:

{
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Warsaw";

  system.stateVersion = "25.05";
}
