{
  services.i2pd.enable = true;

  services.i2pd = {
    proto.http.enable = true;
    proto.httpProxy.enable = true;
    proto.sam.enable = true;
    proto.socksProxy.enable = true;

    bandwidth = 12500;
  };
}
