{
	services.unbound = {
    enable = true;
    settings = {
        server = {
          interface = [ "127.0.0.1" "::1" ];

          qname-minimisation = true;
          prefetch = true;
          prefetch-key = true;

          msg-cache-size = "128m";
          rrset-cache-size = "256m";
        };
    };
  };

  networking.nameservers = [ "127.0.0.1" "::1" ];
  networking.networkmanager.dns = "none";
}
