{
  users.groups.tm = { };
  users.users.tm = {
    isSystemUser = true;
    group = "tm";
  };

  # backups live on one of your disks; 0700 keeps NFS clients (uid 1002) out
  systemd.tmpfiles.rules = [
    "d /shares/megaraid/timemachine 0700 tm tm -"
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "hosts allow" = "192.168.0.0/24 100.64.0.0/10 127.0.0.1";
        "hosts deny" = "ALL";
        "vfs objects" = "catia fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
      };
      timemachine = {
        path = "/shares/megaraid/timemachine";
        "valid users" = "tm";
        "read only" = "no";
        "fruit:time_machine" = "yes";
        "fruit:time_machine_max_size" = "512G";
      };
    };
  };
}
