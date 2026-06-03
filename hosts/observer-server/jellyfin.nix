{ username, ... }: {
    services.jellyfin = {
        enable = true;
        openFirewall = true;
        user = username;
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/var/lib/jellyfin"
        ];
    };
}
