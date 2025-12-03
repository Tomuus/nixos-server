#!!!REMEMBER TO CHOWN THE SHARE DIRECTORY!!!

{ ... }:

{
  services.samba.settings = {
    "jedentb" = {
      "path" = "/shares/jedentb";
      "browseable" = "yes";
      "read only" = "yes"; #The write permission will be set separately
      "guest ok" = "no";
      "create mask" = "0660";
      "directory mask" = "0770";

      "valid users" = " @jedn @samba "; #the RO access list
      "write list" = " @jedn @samba "; #the RW access list (for rw user needs to be included in both)

      "force user" = "smb";
      "force group" = "samba";
    };

    "pienctb" = {
      "path" = "/shares/piectb";
      "browseable" = "yes";
      "read only" = "yes"; #The write permission will be set separately
      "guest ok" = "no";
      "create mask" = "0660";
      "directory mask" = "0770";

      "valid users" = " @pienc @samba "; #the RO access list
      "write list" = " @pienc @samba "; #the RW access list (for rw user needs to be included in both)

      "force user" = "smb";
      "force group" = "samba";
    };

  };
}

