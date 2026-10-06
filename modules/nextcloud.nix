{ config, lib, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.tomuus.org";
    package = pkgs.nextcloud33;

    home = "/var/lib/nextcloud";

    config = {
      adminpassFile = "/var/lib/nextcloud-admin-pass";
      adminuser = "admin";
      dbtype = "pgsql";
    };

    settings = {
      datadirectory = lib.mkForce "/shares/megaraid/data";

      trusted_domains = [
        "nextcloud.tomuus.org"
        "100.97.47.41"
      ];

      "memories.exiftool" = "${pkgs.exiftool}/bin/exiftool";
      "memories.exiftool_no_local" = true;

      # fixes the red "ffmpeg preview binary not found" warning
      preview_ffmpeg_path = "${pkgs.ffmpeg}/bin/ffmpeg";
    };

    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        memories
        previewgenerator;

      camerarawpreviews = pkgs.fetchNextcloudApp {
        url = "https://github.com/ariselseng/camerarawpreviews/releases/download/v1.1.4/camerarawpreviews_nextcloud.tar.gz";
        hash = "sha256-Fg+QsjVIxndQMVrMsMcVK7uhv0c5j92qrYjEOhsA7O4=";
        license = "agpl3Plus";
      };
    };
    extraAppsEnable = true;

    database.createLocally = true;

    phpOptions = {
      "umask" = "0007";
      "memory_limit" = lib.mkForce "1G";
    };
  };
  services.postgresql.enable = true;

  systemd.services.nextcloud-setup = {
    after = [
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
