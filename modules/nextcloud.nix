{ config, pkgs, ... }:

{
  # Enable Nextcloud
  services.nextcloud = {
    enable = true;
    hostName = "100.97.47.41";
		package = pkgs.nextcloud33;
    
		datadir = "/shares/megaraid";

    config = {
      adminpassFile = "/run/secrets/nextcloud-admin-pass";  
      adminuser = "admin";
      dbtype = "pgsql";  
    };
    
    database.createLocally = true; 
  };

  # Enable PostgreSQL
  services.postgresql.enable = true;

	systemd.services.nextcloud-setup = {
		after = [ "mnt-shares-piectb.mount" "mnt-shares-megaraid.mount" ];
		requires = [ "mnt-shares-piectb.mount" "mnt-shares-megaraid.mount" ];
	};

	users.users.nextcloud.extraGroups = [ "samba" ];

 /*	systemd.services.nextcloud-setup.serviceConfig.User = "smb";
	systemd.services.nextcloud-setup.serviceConfig.Group = "samba";
	systemd.services.phpfpm-nextcloud.serviceConfig.User = "smb";
	systemd.services.phpfpm-nextcloud.serviceConfig.Group = "samba"; */
}
