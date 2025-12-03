{ pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";

    extraSetFlags = [
      "--advertise-exit-node"
    ];   
  };

  environment.systemPackages = with pkgs; [
    tailscale
  ];
}
