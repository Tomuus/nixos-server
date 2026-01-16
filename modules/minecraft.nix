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
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_8;
        serverProperties = {
          server-port = 25564;
					view-distance = 20;
        };
				jvmOpts = "-Xmx8G -Xms4G";
      };
      
      demomisiopysio = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_1;
        serverProperties = {
          server-port = 25563;
					spawn-protection=0;
					simulation-distance=10;
					view-distance = 20;
					motd = "spszedam zdjencia stupek Gorgla 10zl/szt";
        };
				jvmOpts = "-Xmx8G -Xms4G";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 25565 25564 25563 ];

  environment.systemPackages = with pkgs; [
    tmux #needed to access server console
  ];
}
