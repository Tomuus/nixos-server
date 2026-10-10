{
  services.i2pd.enable = true;

  services.i2pd = {
    proto.http.enable = true;
    proto.httpProxy.enable = true;
    proto.sam.enable = true;
    proto.socksProxy.enable = true;

    ntcp2 = {
      enable = true;
      published = true;
      port = 21376;
    };

    ssu2 = {
      enable = true;
      published = true;
      port = 21376;
    };

    bandwidth = 6000;
    port = 21376;
  };

  networking.firewall.allowedUDPPorts = [ 21376 ];
  networking.firewall.allowedTCPPorts = [ 21376 ];
}
