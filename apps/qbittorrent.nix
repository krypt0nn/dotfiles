{ username, pkgs, ... }: {
    environment.systemPackages = [ pkgs.qbittorrent ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".config/qBittorrent"
            ".local/share/qBittorrent"
        ];
    };
}
