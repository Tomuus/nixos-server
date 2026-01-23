{ ... }:

{
	environment.etc."tips".source = ./tips;

	programs.rust-motd.enable = true;

	programs.rust-motd.settings = {
		global = {
			version = "1.0";
		};

		banner = {
			command = "shuf -n 1 /etc/tips | /run/current-system/sw/bin/cowsay";
			color = "white";
		};
	};
}


