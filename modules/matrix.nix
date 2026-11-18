{ unstbl, ... }:

{
  services.matrix-continuwuity = {
    enable = true;
    #package = unstbl.matrix-continuwuity;

    settings = {
      global = {
        allow_encryption = true;
        allow_federation = true;
        allow_registration = false;

        server_name = "tomuus.org";

        trusted_servers = [ "matrix.org" "unredacted.org" "grapheneos.org" ];
        address = [ "127.0.0.1" ];

        well_known = {
          client = "https://matrix.tomuus.org";
          server = "matrix.tomuus.org:443";
        };
      };
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."matrix.tomuus.org".extraConfig = ''
      reverse_proxy localhost:6167
    '';
    virtualHosts."tomuus.org".extraConfig = ''
      reverse_proxy /.well-known/matrix/* localhost:6167
    '';
  };

  services.matrix-continuwuity.package = unstbl.matrix-continuwuity.overrideAttrs (old: {
     patches = (old.patches or [ ]) ++ [ ./cont.patch ];
   });
}
