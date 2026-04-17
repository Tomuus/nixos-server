{ config, pkgs, ... }:

{
  # Enable Nextcloud
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.tomuus.org";
		package = pkgs.nextcloud33;
    
		datadir = "/shares/megaraid";
		home = "/var/lib/nextcloud";

    config = {
      adminpassFile = "/run/secrets/nextcloud-admin-pass";  
      adminuser = "admin";
      dbtype = "pgsql"; 
			extraTrustedDomains = [ "100.97.47.41" ];
    };
    
    database.createLocally = true; 
  };

  # Enable PostgreSQL
  services.postgresql.enable = true;

	systemd.services.nextcloud-setup = {
		after = [ "shares-piectb.mount" "shares-megaraid.mount" ];
		requires = [ "shares-megaraid.mount" ];
	};

	users.users.nextcloud.extraGroups = [ "samba" ];

	systemd.services.phpfpm-nextcloud.serviceConfig.UMask = "0007";
}
