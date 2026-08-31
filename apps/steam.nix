{ ... }: {
    programs.steam = {
        enable = true;
        dedicatedServer.openFirewall = true;
    };
}
