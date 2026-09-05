{
  description = "Nixos flake for my servers";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    
    ortho4xp-src = { url = "github:shred86/Ortho4XP"; flake = false; };

  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      unstbl = nixpkgs-unstable.legacyPackages.${system};
      mods = ./modules; # same as in Tomuus/nixfiles (easier imports)
     ortho4xpEnv = pkgs.python3.withPackages (ps: with ps; [
      gdal
      pillow
      numpy
      shapely
      rtree
      pyproj
      requests
      scikit-fmm
      tkinter
    ]);      
      in
    {
      nixosConfigurations = {
        Laptop = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs unstbl mods; };
          modules = [
            ./hosts/laptop/configuration.nix
            ./common
          ];
        };
        Serwer = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs unstbl mods ortho4xpEnv; };
          modules = [
            ./hosts/serwer/configuration.nix
            ./common
          ];
        };
      };
    };
}
