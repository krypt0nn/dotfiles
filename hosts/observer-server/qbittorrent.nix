{ username, ... }: {
    services.qbittorrent = {
        enable = true;
        openFirewall = true;
        webuiPort = 9030;
        torrentingPort = 9090;
        user = username;
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/var/lib/qBittorrent"
        ];
    };
}
