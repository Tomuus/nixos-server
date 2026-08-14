{ ... }:

{
  services.navidrome = {
    enable = true;
    openFirewall = true;

    #Let's be lazy
    user = "smb";
    group = "samba";

    settings = {
      MusicFolder = "/shares/megaraid/Music";
      Address = "0.0.0.0";
    };
  }; 
}
