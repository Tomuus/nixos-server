{ unstbl, ... }:

{
  services.minecraft-server = {
    enable = true;
    openFirewall = true;
    eula = true;
    declarative = true;
    jvmOpts = "-Xmx2048M -Xms8192M";
    serverProperties = {
      server-port = 25565;
      difficulty = 3;
      gamemode = 1;
      max-players = 20;
      motd = "NixOS Minecraft server";
      white-list = false;
      enable-rcon = true;
      "rcon.password" = "hunter2";
    };

    package = unstbl.papermcServers.papermc-1_21_8;
  };
}
