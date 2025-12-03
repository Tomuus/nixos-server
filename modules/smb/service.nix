{ pkgs, ... }:

{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        #yeah idk how the 2 lines under this work but these were in the tutorial
        "guest account" = "nobody";
        "map to guest" = "bad user";

        "aio read size" = "1";
        "aio write size" = "1";

        "strict sync" = "no";
        "sync always" = "no";

        "min receivefile size" = "16384";
        "read raw" = "yes";
        "write raw" = "yes";

        "use sendfile" = "yes";

        "server min protocol" = "SMB2";
        "server multi channel support" = "yes";
      };
    };
  };
  
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [ samba cifs-utils ];
}
