{
  services.umurmur = {
    enable = true;
    openFirewall = true;
    configFile = "/etc/umurmur.conf";
  };

  networking.firewall.allowedTCPPorts = [ 64738 ];
  networking.firewall.allowedUDPPorts = [ 64738 ];
}
