{ mods, ortho4xpEnv, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    "${mods}/minecraft.nix"
    "${mods}/tailscale.nix"
    "${mods}/smb"
    "${mods}/qbittorrent.nix"
    "${mods}/forgejo.nix"
    "${mods}/nextcloud.nix"
    "${mods}/cloudflare.nix"
    "${mods}/nfs.nix"
    "${mods}/resolve-server.nix"
    "${mods}/timemachine.nix"
    "${mods}/spl.nix"
    "${mods}/immich.nix"
    "${mods}/navidrome.nix"
    "${mods}/i2p.nix"
    "${mods}/nvidia.nix"
    "${mods}/ortho.nix"
  ];

  virtualisation.docker.enable = true;
  networking.hostName = "Serwer";
  environment.systemPackages = [ ortho4xpEnv ];
 services.smartd = {
  enable = true;
  autodetect = true;    
  notifications.wall.enable = true;   
  }; #sorry tomek ale nie robie nowego pliku dla tego bs 
  nixpkgs.overlays = [
    (final: prev: {
      ps3netsrv = prev.ps3netsrv.overrideAttrs (old: {
        version = "20260913";
        sourceRoot = "source";
        src = prev.fetchFromGitHub {
          owner = "aldostools";
          repo = "ps3netsrv";
          rev = "20260913";
          hash = "sha256-Lsazt178L6oP9AzpKs4MP6aMRFq7HydJ/uVZMYbOWGE=";
        };
      });
    })
  ];
}
