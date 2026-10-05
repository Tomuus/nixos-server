{ config, lib, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.tomuus.org";
    package = pkgs.nextcloud33;

    # No separate datadir: config/ lives under home, which is root-owned all the way up
    home = "/var/lib/nextcloud";

    config = {
      adminpassFile = "/var/lib/nextcloud-admin-pass";
      adminuser = "admin";
      dbtype = "pgsql";
    };

    settings = {
      # User files stay on the share
      datadirectory = lib.mkForce "/shares/megaraid/data";

      trusted_domains = [
        "nextcloud.tomuus.org"
        "100.97.47.41"
      ];

      # Memories: use the Nix-provided exiftool instead of downloading one
      "memories.exiftool" = "${pkgs.exiftool}/bin/exiftool";
      "memories.exiftool_no_local" = true;
    };

    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        memories
        previewgenerator;
    };
    extraAppsEnable = true;

    database.createLocally = true;

    phpOptions = {
      "umask" = "0007";
    };
  };

  services.postgresql.enable = true;

  systemd.services.nextcloud-setup = {
    after = [
      "shares-piectb.mount"
      "shares-megaraid.mount"
    ];
    requires = [ "shares-megaraid.mount" ];
    serviceConfig.UMask = "0007";
  };

  users.users.nextcloud.extraGroups = [ "samba" ];

  systemd.services.phpfpm-nextcloud = {
    path = [ pkgs.exiftool pkgs.ffmpeg ];
    serviceConfig.UMask = lib.mkForce "0007";
  };

  systemd.services.nextcloud-cron.serviceConfig.UMask = "0007";
}
