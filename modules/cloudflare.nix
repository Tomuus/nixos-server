{ pkgs, ... }:

{
	services.cloudflared = {
		enable = true;

		tunnels = {
			"5ac4b348-f410-49cc-a3d5-2a6b22020867" = {
				credentialsFile = "/etc/cloudflared/5ac4b348-f410-49cc-a3d5-2a6b22020867.json";
				default = "http_status:404";
				ingress = {
					"nextcloud.tomuus.org" = "http://localhost:80";
				};
			};
		};
	};

	environment.systemPackages = with pkgs; [
		cloudflared
	];
}
