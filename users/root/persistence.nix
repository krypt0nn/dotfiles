{ ... }: {
    environment.persistence."/persistent" = {
        hideMounts = true;

        users.root = {
            directories = [
                # Default folders
                "Desktop"
                "Documents"
                "Downloads"
                "Music"
                "Pictures"
                "Public"
                "Videos"
                "Templates"

                # Apps folders
                ".local"
                ".config"

                { directory = ".gnupg"; mode = "0700"; }
                { directory = ".ssh"; mode = "0700"; }
                { directory = ".local/share/keyrings"; mode = "0700"; }
            ];

            files = [
                ".back_history"
                ".nix-channels"
            ];
        };
    };
}
