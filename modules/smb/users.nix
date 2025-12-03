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

    miki = {
      isNormalUser = true; #not sure if this is the right choice but system users are more like for services or smth
      shell = "/run/current-system/sw/bin/nologin";
      createHome = false;
      extraGroups = [ "pienc" "jedn" ];
    };
    tomus = {
      isNormalUser = true; #not sure if this is the right choice but system users are more like for services or smth
      shell = "/run/current-system/sw/bin/nologin";
      createHome = false;
      extraGroups = [ "pienc" "jedn" ];
    };

    smb = {
      isNormalUser = true; #not sure if this is the right choice but system users are more like for services or smth
      shell = "/run/current-system/sw/bin/nologin";
      createHome = false;
      extraGroups = [ "samba" "pienc" "jedn" ];
    };
  };

  users.groups = {
    pienc = {}; #creating groups is simple af
    jedn = {};
    samba = {};
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
