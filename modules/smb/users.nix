#users.nix
#file for smb users

{ ... }:

{
  users.users = {
    test = {
      isNormalUser = true; #not sure if this is the right choice but system users are more like for services or smth
      shell = "/run/current-system/sw/bin/nologin";
      createHome = false;
    };
  };
}

#''
#===Share account schema===
#user = {
#    isNormalUser = true; 
#    shell = "/run/current-system/sw/bin/nologin";
#    home = null;
#    createHome = false;
#  };
#};
#
#!!!remember to add him to smb
#smbpasswd -a user
#
#''
