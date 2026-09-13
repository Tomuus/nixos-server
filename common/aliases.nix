{ ... }:

{
  environment.shellAliases = {
    ff = "fastfetch";
    gd = "git diff";
    gp = "git pull";
    gs = "git status";
    nxrs = "sudo nixos-rebuild switch --flake .#";
  };
}
