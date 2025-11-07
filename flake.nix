{
  description = "Nixos flake for my servers";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

  };
  outputs = { self, nixpkgs, nixpkgs-unstable, ... } @ inputs:
  let 
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    unstbl = nixpkgs-unstable.legacyPackages.${system};
    mods = ./modules; #same as in Tomuus/nixfiles (easier imports)
  in 
  {
    nixosConfigurations = {
      Minecraft = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit inputs unstbl mods; };
        modules = [
         ./hosts/minecraft/configuration.nix
         ./common
        ];
      };
      Forgejo = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit inputs unstbl mods; };
        modules = [
          ./hosts/forgejo/configuration.nix 
          ./common
        ];
      };
      Serwer = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit inputs unstbl mods; };
        modules = [
          ./hosts/serwer/configuration.nix 
          ./common
        ];
      };
    };
  };
}
