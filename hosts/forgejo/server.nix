{ unstbl, ... }:

{
  services.forgejo = {
    enable = true;
    settings.server.DOMAIN = "192.168.0.29";
  };

  networking.firewall.allowedTCPPorts = [ 22 3000 ];
}
