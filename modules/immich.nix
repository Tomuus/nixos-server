{ unstbl, ... }:

{
  services.immich = {
    enable = true;
    package = unstbl.immich;

    port = 2283;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/shares/megaraid/immich";
  };
}
