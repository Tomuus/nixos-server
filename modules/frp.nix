{
  services.frp = {
    instances."klocki" = {
      enable = true;
      role = "client";
      settings = {
        proxies = [
        {
          localIP = "127.0.0.1";
          localPort = 25566;
          name = "klocki";
          remotePort = 25565;
          type = "tcp";
        }
        ];
        serverAddr = "vps.tomuus.org";
        serverPort = 7000;
        
        auth.method = "token";
        auth.token = "{{ .Envs.SECRET_TOKEN }}";
      };
      environmentFiles = [ "/etc/frpc" ];
    };
  };
}
