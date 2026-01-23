{ ... }:

{
  imports = [
    ./system-properties.nix
    ./admin.nix
    ./services.nix
    ./packages.nix
		./motd.nix
  ];
}
