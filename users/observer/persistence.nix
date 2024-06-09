{ ... }: {
    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
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

                # Personal folders
                "projects"

                # Apps folders
                ".zsh"
                ".syncthing"

                ".local"

                { directory = ".config"; mode = "0755"; }

                { directory = ".gnupg"; mode = "0700"; }
                { directory = ".ssh"; mode = "0700"; }
                { directory = ".pki"; mode = "0700"; }
                { directory = ".local/share/keyrings"; mode = "0700"; }

                { directory = ".local/share/Trash"; mode = "0755"; }
            ];

            files = [
                # Zsh
                ".zshrc"
                ".zshenv"
                ".zsh_history"
                ".zcompdump"
            ];
        };
    };
}
