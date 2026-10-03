{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ps3netsrv
  ];
}
