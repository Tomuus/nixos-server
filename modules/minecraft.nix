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
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_8;
        serverProperties = {
          server-port = 25565;
        };
      };

      nigland = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_8;
        serverProperties = {
          server-port = 25564;
        };
      };
      
      demogorgiel = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_1;
        serverProperties = {
          server-port = 69420;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    tmux #needed to access server console
  ];
}
