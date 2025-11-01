{ pkgs, ... }:

{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "dd74413c-1fc1-4179-ad0a-20e5a618b4ff" = {
        credentialsFile = "/etc/cloudflared/dd74413c-1fc1-4179-ad0a-20e5a618b4ff.json";
        default = "http_status:404";
        ingress = {
          "forge.tomuus.org" = {
            service = "http://localhost:3000";
          };
	  "szybki.tomuus.org" = {
	    service = "ssh://localhost:22";
	  };
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    cloudflared
  ];
}
