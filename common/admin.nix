#The admin user

{ pkgs, ... }:

{
  users.users.admin = {
    description = "System Administrator";
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "wheel" "docker" "samba" "minecraft" ];
    openssh.authorizedKeys.keyFiles = [
      ./sshKeys.pub
    ];
  };
}
