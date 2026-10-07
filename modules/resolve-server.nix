{ ... }:
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
}
