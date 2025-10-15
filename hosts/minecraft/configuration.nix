{ ... }:

{
  imports = [
    ./hardware-configuration.nix 
    ./server.nix
  ];

  networking.hostName = "minecraft";
}
