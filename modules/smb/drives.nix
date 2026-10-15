{ pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "a1f9c2e3";

  boot.zfs.extraPools = [
    # "piectb"
    "megaraid"
    "fast"
  ];

  environment.systemPackages = with pkgs; [
    smartmontools
  ];

  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  services.smartd = {
    enable = true;
    autodetect = true;    
    notifications.wall.enable = true;   
  }; 

  #  fileSystems."/shares/jedentb" = {
  #    device = "jedentb";
  #    fsType = "zfs";
  #  };
  #
  #  fileSystems."/shares/piectb" = {
  #    device = "piectb";
  #    fsType = "zfs";
  #  };
}
