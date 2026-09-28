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
