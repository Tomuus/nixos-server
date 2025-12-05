{ ... }:

{
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PrintMotd = true;
  };
}
