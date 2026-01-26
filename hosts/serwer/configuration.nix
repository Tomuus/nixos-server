{ mods, ... }:

{
  imports = [
    ./hardware-configuration.nix 
    "${mods}/minecraft.nix"
    "${mods}/tailscale.nix"
    "${mods}/smb"
    "${mods}/qbittorrent.nix"
    "${mods}/forgejo.nix"
    #"${mods}/nfs.nix"
#    "${mods}/jellyfin.nix"
  ];

  virtualisation.docker.enable = true;
  networking.hostName = "Serwer";
}
