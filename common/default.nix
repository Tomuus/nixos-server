{ ... }:

{
  imports = [
    ./system-properties.nix
    ./admin.nix
    ./aliases.nix
    ./services.nix
    ./packages.nix
    ./motd.nix
  ];
}
