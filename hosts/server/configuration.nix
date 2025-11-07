{ mods, ... }:

{
  imports = [
    ./hardware-configuration.nix 
    "${mods}/minecraft.nix"
    "${mods}/forgejo.nix"
  ];

  virtualisation.docker.enable = true;
  networking.hostName = "Serwer";
}
