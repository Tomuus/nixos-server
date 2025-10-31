{
  description = "Nixos flake for my servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, ... } @ inputs:
  let 
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    unstbl = nixpkgs-unstable.legacyPackages.${system};
  in 
  {
    nixosConfigurations = {
      Minecraft = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit inputs unstbl; };
        modules = [
         ./hosts/minecraft/configuration.nix
         ./common/default.nix
        ];
      };
      Forgejo = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit inputs unstbl; };
        modules = [
          ./hosts/forgejo/configuration.nix 
          ./common/default.nix
        ];
      };
    };
  };
}
