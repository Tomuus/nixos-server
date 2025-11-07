#The admin user

{ pkgs, ... }:

{
  users.users.admin = {
    description = "System Administrator";
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "wheel", "docker" ];
    openssh.authorizedKeys.keyFiles = [
      ./sshKeys.pub
    ];
  };
}
