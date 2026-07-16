{ username, pkgs, ... }: {
    time.timeZone = "Europe/Kaliningrad";

    i18n.defaultLocale = "en_US.UTF-8";

    services.xserver.xkb.layout = "us,ru";

    users = {
        mutableUsers = false;

        users = {
            root = {
                createHome = true;

                shell = pkgs.bash;

                name = "root";
                home = "/root";

                uid = 0;

                hashedPasswordFile = "/persistent/root.password";
            };

            observer = {
                isNormalUser = true;
                createHome = true;

                # useDefaultShell = true;
                shell = pkgs.fish;

                name = username;
                home = "/home/${username}";

                hashedPasswordFile = "/persistent/${username}.password";

                extraGroups = [
                    "wheel"
                    "networkmanager"
                    "libvirtd"
                    "podman"
                    "render"
                    "video"
                    "gamemode"
                ];
            };
        };
    };

    environment.variables = {
        XDG_CACHE_HOME  = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME   = "$HOME/.local/share";
        XDG_STATE_HOME  = "$HOME/.local/state";
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            # Default folders
            "Desktop"
            "Documents"
            "Projects"
            "Downloads"
            "Music"
            "Pictures"
            "Public"
            "Videos"
            "Templates"

            # Monitor ICC profiles
            ".local/share/icc"

            ".local"
            ".config"

            { directory = ".ssh"; mode = "0700"; }
            { directory = ".pki"; mode = "0700"; }
            { directory = ".local/share/keyrings"; mode = "0700"; }
        ];
    };
}
