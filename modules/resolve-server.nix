{ pkgs, ... }:
{
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.resolve-db = {
    image = "postgres:13";
    # Docker-published ports bypass the firewall, so bind to specific IPs
    ports = [ "192.168.0.67:5432:5432" "100.97.47.41:5432:5432" ];
    environmentFiles = [ "/etc/resolve-db.env" ];
    volumes = [ "/shares/fast/pgdata:/var/lib/postgresql/data" ];
  };

  systemd.services.docker-resolve-db = {
    after = [ "zfs-mount.service" "tailscaled.service" ];
    requires = [ "zfs-mount.service" ];
  };
    systemd.services.resolve-db-backup = {
    serviceConfig.Type = "oneshot";
    path = [ pkgs.docker pkgs.gzip pkgs.coreutils pkgs.findutils ];
    script = ''
      set -eu
      dir=/shares/megaraid/backups/resolve-db
      mkdir -p "$dir"
      docker exec resolve-db pg_dumpall -U postgres | gzip > "$dir/$(date +%F).sql.gz.part"
      mv "$dir/$(date +%F).sql.gz.part" "$dir/$(date +%F).sql.gz"
      find "$dir" -name '*.sql.gz' -mtime +30 -delete
    '';
  };

  systemd.timers.resolve-db-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "00:00";
      Persistent = true;
    };
  };

  # optional: age out old cache files so the 200G quota never fills
  systemd.tmpfiles.rules = [
    "e /shares/fast/cache/pc - - - 30d"
    "e /shares/fast/cache/mac - - - 30d"
  ];
}
