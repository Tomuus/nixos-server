{ mods, ... }:

{
  imports = [
    ./hardware-configuration.nix 
    "${mods}/forgejo.nix"
    ./cloudflared.nix
  ];

  networking.hostName = "Forgejo";
}
