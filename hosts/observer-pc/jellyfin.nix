{ ... }: {
    services.jellyfin = {
        enable = true;
        openFirewall = true;
        user = "observer";
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/var/lib/jellyfin"
        ];
    };
}
