{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    glances
    lm_sensors
    smartmontools
  ];

  # Optional: start the web UI automatically at boot
  systemd.services.glances = {
    description = "Glances web UI";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.lm_sensors pkgs.smartmontools ];
    serviceConfig = {
      ExecStart = "${pkgs.glances}/bin/glances -w -B 127.0.0.1";
      Restart = "on-failure";
    };
  };
}
