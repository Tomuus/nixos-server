{ ... }:

{
  services.static-web-server = {
    enable = true;
    listen = "127.0.0.1:8085";
    root = "/var/www/spl";
  };

  systemd.tmpfiles.rules = [
    "d /var/www/spl 0755 admin users -"
  ];
}
