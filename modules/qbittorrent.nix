{ pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [ qbittorrent ];
}
