{ pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    serverConfig = 
    {
      LegalNotice.Accepted = true;
      Preferences = {
       WebUI = {
         Username = "user";
#         Password_PBKDF2 = "12345678";
      };
      General.Locale = "en";
      };
    };

  };

	users.users.qnittorrent.extraGroups = [ "samba" ];
  environment.systemPackages = with pkgs; [ qbittorrent ];
}
