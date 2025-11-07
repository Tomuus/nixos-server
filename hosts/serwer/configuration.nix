{ mods, ... }:

{
  imports = [
    ./hardware-configuration.nix 
    "${mods}/minecraft.nix"
    "${mods}/forgejo.nix"
    "${mods}/smb"
  ];

  virtualisation.docker.enable = true;
  networking.hostName = "Serwer";
}
