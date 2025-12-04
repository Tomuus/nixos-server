{ ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "a1f9c2e3";

  boot.zfs.extraPools = [ "piectb" "megaraid" ];
  
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
