{ mods, ortho4xpEnv, ... }:

{
  imports = [
    ./hardware-configuration.nix
    "${mods}/minecraft.nix"
    "${mods}/tailscale.nix"
    "${mods}/smb"
    "${mods}/qbittorrent.nix"
    "${mods}/forgejo.nix"
    "${mods}/nextcloud.nix"
    "${mods}/cloudflare.nix"
    "${mods}/nfs.nix"
    "${mods}/immich.nix"
    "${mods}/navidrome.nix"
  ];

  virtualisation.docker.enable = true;
  networking.hostName = "Serwer";
  environment.systemPackages = [ ortho4xpEnv ];
}
