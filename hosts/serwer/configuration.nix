{ mods, ... }:

{
  imports = [
    ./hardware-configuration.nix 
#    "${mods}/minecraft.nix"
    "${mods}/smb"
    "${mods}/tailscale.nix"
    "${mods}/forgejo.nix"
#    "${mods}/jellyfin.nix"
  ];

  virtualisation.docker.enable = true;
  networking.hostName = "Serwer";
}
