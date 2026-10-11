{ pkgs, ... }:

let
  web = pkgs.runCommand "f1-web" { } ''
    mkdir -p $out
    cp ${./f1-index.html} $out/index.html
  '';
in
{
  # F1 prediction game for friends, listens on 127.0.0.1:8087 (reached through the Cloudflare tunnel).
  # Needs /etc/f1-invite (root-readable file with the invite code friends type when registering).
  systemd.services.f1-game = {
    description = "F1 prediction game";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    unitConfig.ConditionPathExists = "/etc/f1-invite";
    environment = {
      F1_WEB = "${web}";
      F1_DATA = "/var/lib/f1-game";
      F1_PORT = "8087";
      F1_SEASON = "2026";
      F1_ADMINS = "miki"; # comma-separated usernames that get the Admin tab
    };
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 ${./f1-game.py}";
      Restart = "on-failure";
      LoadCredential = "invite:/etc/f1-invite";
      DynamicUser = true;
      StateDirectory = "f1-game";
      MemoryMax = "200M";
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
}
