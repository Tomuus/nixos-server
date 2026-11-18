{ config, pkgs, ... }:

let
  glancesGpu = pkgs.glances.overridePythonAttrs (old: {
    dependencies = (old.dependencies or []) ++ [ pkgs.python3Packages.nvidia-ml-py ];
  });
in
{
    boot.kernelModules = [ "drivetemp" ];

  systemd.services.glances = {
    description = "Glances web UI";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.lm_sensors pkgs.smartmontools ];
        environment.LD_LIBRARY_PATH = "/run/opengl-driver/lib";
    serviceConfig = {
      ExecStart = "${glancesGpu}/bin/glances -w -B 127.0.0.1";
      Restart = "on-failure";
    };
  };
}
