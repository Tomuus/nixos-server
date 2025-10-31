{ ... }:

{
  imports = [
    ./hardware-configuration.nix 
    ./server.nix
    ./cloudflared.nix
  ];

  networking.hostName = "Forgejo";
}
