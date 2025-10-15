{
  description = "Nixos flake for my servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
  };
  outputs = { self, nixpkgs, ... } @ inputs:
  let 
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in 
  {
    nixosConfigurations = {
      Minecraft = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit inputs; };
        modules = [
         ./hosts/minecraft/configuration.nix
         ./common/system-properties.nix
        ];
      };
    };
  };
}
