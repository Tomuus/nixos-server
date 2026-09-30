{ pkgs, ... }:

{
  # SPL quiz page + weekly leaderboard (replaces static-web-server), listens on 127.0.0.1:8086
  systemd.services.spl-board = {
    description = "SPL quiz and weekly leaderboard";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      SPL_WEB = "/var/www/spl";
      SPL_DB = "/var/lib/spl-board/board.db";
      SPL_PORT = "8086";
    };
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 ${./spl-board.py}";
      Restart = "on-failure";
      DynamicUser = true;
      StateDirectory = "spl-board";
      ReadOnlyPaths = [ "/var/www/spl" ];
      MemoryMax = "150M";
      TasksMax = 64;
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      LockPersonality = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
      SystemCallFilter = [ "@system-service" ];
      SystemCallArchitectures = "native";
    };
  };

  systemd.tmpfiles.rules = [ "d /var/www/spl 0755 admin users -" ];
}
