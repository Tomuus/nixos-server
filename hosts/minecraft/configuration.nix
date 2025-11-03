{ mods, ... }:

{
  imports = [
    ./hardware-configuration.nix 
    "${mods}/minecraft.nix"
  ];

  networking.hostName = "Minecraft";
}
