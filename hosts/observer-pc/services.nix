{ ... }: {
    services.jellyfin = {
        enable = true;
        openFirewall = true;
        user = "observer";
    };
}
