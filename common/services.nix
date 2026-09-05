{ ... }:

{
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    X11Forwarding = true;
    #    PrintMotd = true;
  };
}
