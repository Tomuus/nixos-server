{ pkgs, inputs, unstbl, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
  
  services.minecraft-servers = {
    enable = true;
    eula = true;
    
    servers = {
      test = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_7;
      };
    };
  };
}
