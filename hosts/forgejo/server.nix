{ unstbl, ... }:

{
  services.forgejo = {
    enable = true;
    settings.server.DOMAIN = "forge.tomuus.org";
    settings.server.ROOT_URL = "https://forge.tomuus.org/";
    settings.git.SSH_DOMAIN = "forge.tomuus.org";
    settings = {
      service = {
        DISABLE_REGISTRATION = true;
        ENABLE_CAPTCHA = true;
        APP_NAME = "Coding goes brrrrrr";
      }
    }
  };

  networking.firewall.allowedTCPPorts = [ 22 3000 ];
}
