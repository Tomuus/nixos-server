{ pkgs, ... }:

{
	services.cloudflared = {
		enable = true;
	};

	environment.systemPackages = with pkgs; [
		cloudflared
	];
}
