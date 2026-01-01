{ ... }: {
    services.jellyfin = {
        enable = true;
        user = "observer";
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/var/lib/jellyfin"
        ];
    };
}
