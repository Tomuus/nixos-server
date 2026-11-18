{ pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          Username = "user";
          Password_PBKDF2 = "@ByteArray(gwt5Fk/hnLkn/2+q3HcErA==:enGoivoku7w1fkNCTv2WDqEOwt7oMIDe9der1HPkSQMSluKwpAbJTdQBumoMrbWFls26jqCG8FcurP+oEN035Q==)";
        };
        General.Locale = "en";
      };

      BitTorrent.Session = {
        QueueingSystemEnabled = false;

        Interface = "";
        InterfaceAddress = "";
        InterfaceName = "";

        MaxConnections = -1;
        MaxConnectionsPerTorrent = -1;
        MaxUploads = -1;
        MaxUploadsPerTorrent = -1;

        GlobalMaxRatio = -1;
        GlobalMaxSeedingMinutes = -1;

        I2P = {
          Enabled = true;
          Address = "127.0.0.1";
          Port = 7656;
          MixedMode = false;
        };
      };
    };

  };


  users.users.qbittorrent.extraGroups = [ "samba" ];
  environment.systemPackages = with pkgs; [ qbittorrent ];
}
