{ ... }:

{
  imports = [
    ./hardware-configuration.nix 
    ./server.nix
    ./../../common/default.nix
  ];

  networking.hostName = "Forgejo";
}
