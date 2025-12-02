#!!!REMEMBER TO CHOWN THE SHARE DIRECTORY!!!

{ ... }:

{
  services.samba.settings = {
    "media" = {
      "path" = "later...";
      "browseable" = "yes";
      "read only" = "yes"; #The write permission will be set separately
      "guest ok" = "no";
      "create mask" = "0660";
      "directory mask" = "0770";

      "valid users" = " ... "; #the RO access list
      "write list" = " ... "; #the RW access list (for rw user needs to be included in both)

      "force user" = "dir_owner";
      "force group" = "dir_group";
    };
  };
}

