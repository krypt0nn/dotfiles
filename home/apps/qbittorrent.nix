{ pkgs, ... }: {
    home.packages = [ pkgs.qbittorrent ];

    home.persistence."/persistent" = {
        directories = [
            ".config/qBittorrent"
            ".local/share/qBittorrent"
        ];
    };
}
