{ pkgs, inputs, unstbl, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
  
  services.minecraft-servers = {
    enable = true;
    eula = true;
    
    servers = {
      duo = {
        enable = false;
        package = pkgs.fabricServers.fabric-1_21_8;
        serverProperties = {
          server-port = 25565;
					view-distance = 20;
        };
      };

      nigland = {
        enable = false;
        package = pkgs.fabricServers.fabric-1_21_8;
        serverProperties = {
          server-port = 25564;
					view-distance = 20;
        };
				jvmOpts = "-Xmx8G -Xms4G";
      };
      
      demomisiopysio = {
        enable = false;
        package = pkgs.fabricServers.fabric-1_21_1;
        serverProperties = {
          server-port = 25563;
					spawn-protection=0;
					simulation-distance=10;
					view-distance = 20;
					motd = "Imagine using Windows fr";
        };
				jvmOpts = "-Xmx8G -Xms4G";
      };
			cokolwiek = {
        enable = false;
        package = pkgs.fabricServers.fabric-1_21_11;
        serverProperties = {
          server-port = 25560;
					view-distance = 20;
        };
				jvmOpts = "-Xmx8G -Xms4G";
      };
			wakacyjny = {
        enable = true;
        package = pkgs.fabricServers.fabric-26_2;
        serverProperties = {
          server-port = 25559;
					spawn-protection=0;
					simulation-distance=20;
					view-distance = 40;
					difficulty = "hard";
					motd = "I use nixos btw";
        };
				jvmOpts = "-Xmx12G -Xms2G";
      };

    };
  };

  networking.firewall.allowedTCPPorts = [ 25565 25564 25563 ];

  environment.systemPackages = with pkgs; [
    tmux #needed to access server console
  ];
}
