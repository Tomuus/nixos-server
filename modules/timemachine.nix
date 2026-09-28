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
  services.avahi = {
    enable = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
    extraServiceFiles.timemachine = ''
      <?xml version="1.0" standalone='no'?>
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name replace-wildcards="yes">%h</name>
        <service>
          <type>_smb._tcp</type>
          <port>445</port>
        </service>
        <service>
          <type>_device-info._tcp</type>
          <port>0</port>
          <txt-record>model=TimeCapsule8,119</txt-record>
        </service>
        <service>
          <type>_adisk._tcp</type>
          <txt-record>dk0=adVN=timemachine,adVF=0x82</txt-record>
          <txt-record>sys=adVF=0x100</txt-record>
        </service>
      </service-group>
    '';
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "hosts allow" = "192.168.0.0/24 100.64.0.0/10 127.0.0.1 ::1 fe80::/10 2a02:a311:4094:fd80::/64";
        "hosts deny" = "ALL";
        "host msdfs" = "no";
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
