{ pkgs, ... }:

{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "25bea3c2-b774-4c17-8f97-ffe568b5a5da" = {
        credentialsFile = "/etc/cloudflared/cert.pem";
        default = "http_status:404";
        ingress = {
          "forgejo.tomuus.org" = {
            service = "http://192.168.0.29:3000";
          };
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    cloudflared
  ];
}
