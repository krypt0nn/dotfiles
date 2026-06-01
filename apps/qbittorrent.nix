{ pkgs, ... }: {
    environment.systemPackages = [ pkgs.qbittorrent ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
            directories = [
                ".config/qBittorrent"
                ".local/share/qBittorrent"
            ];
        };
    };
}
