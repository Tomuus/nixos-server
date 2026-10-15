{ pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "a1f9c2e3";

  boot.zfs.extraPools = [
    # "piectb"
    "megaraid"
    "fast"
  ];

  fileSystems."/shares/bigblack" = {
    device = "/dev/disk/by-uuid/c1b8d8a8-cfa6-4f66-a6a4-661906abf6a3";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

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
