#users.nix
#file for smb users

{ ... }:

{
  users.users = {
    test = {
      isNormalUser = true; #not sure if this is the right choice but system users are more like for services or smth
      shell = "/run/current-system/sw/bin/nologin";
      createHome = false;
      extraGroups = [  ];
    };
  };

  users.groups = {
    #groupname = {}; #creating groups is simple af
  };
}

#''
#===Share account schema===
#user = {
#    isNormalUser = true; 
#    shell = "/run/current-system/sw/bin/nologin";
#    createHome = false;
#    extraGroups = [  ]; #add groups here
#  };
#};
#
#!!!REMEMBER TO ADD YOUR USER TO SMB!!!
#smbpasswd -a user
#
#''
