{ config, lib, pkgs, modulesPath, ... }:

{
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };
  swapDevices = [];
}
