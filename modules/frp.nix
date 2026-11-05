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
        { 
          name = "matrix-https"; 
          type = "tcp"; 
          localIP = "127.0.0.1"; 
          localPort = 443; 
          remotePort = 443; 
        }
        { 
          name = "matrix-http";  
          type = "tcp"; 
          localIP = "127.0.0.1"; 
          localPort = 80;  
          remotePort = 80; 
        }
        ];
        serverAddr = "84.32.98.118";
        serverPort = 7000;
        
        auth.method = "token";
        auth.token = "{{ .Envs.SECRET_TOKEN }}";
      };
      environmentFiles = [ "/etc/frpc" ];
    };
  };
}
