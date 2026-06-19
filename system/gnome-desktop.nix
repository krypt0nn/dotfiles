{ username, pkgs, ... }:
    let
        wallpaperLightImg = ./../images/wallpaper-light.jpg;
        wallpaperDarkImg = ./../images/wallpaper-dark.jpg;
        screensaverImg = ./../images/screensaver.jpg;
        profileImg = ./../images/profile.jpg;
    in {
        # Enable gnome
        services.displayManager.gdm.enable = true;
        services.desktopManager.gnome.enable = true;

        # Add some apps and extensions
        environment.systemPackages = with pkgs; [
            mission-center
            gnome-extension-manager
            loupe
            vlc
            file-roller
            crosspipe
            apostrophe

            # Setup GNOME extensions
            gnomeExtensions.appindicator
            gnomeExtensions.blur-my-shell
            gnomeExtensions.night-theme-switcher
            gnomeExtensions.caffeine
            gnomeExtensions.tiling-shell
        ];

        # Remove unneeded built-in gnome apps
        environment.gnome.excludePackages = with pkgs; [
            cheese eog epiphany simple-scan showtime yelp geary
            gnome-calendar gnome-characters gnome-contacts
            gnome-font-viewer gnome-logs gnome-maps gnome-music
            gnome-system-monitor gnome-connections
            gnome-tour snapshot gnome-console
            gnome-shell-extensions
        ];

        # Setup gnome settings
        services.desktopManager.gnome.extraGSettingsOverrides = ''
            [org.gnome.desktop.input-sources]
            sources=[('xkb', 'us'), ('xkb', 'ru')]
            show-all-sources=true

            [org.gnome.desktop.background]
            picture-uri='file://${wallpaperLightImg}'
            picture-uri-dark='file://${wallpaperDarkImg}'

            [org.gnome.desktop.screensaver]
            picture-uri='file://${screensaverImg}'
        '';

        # Set user profile picture
        system.activationScripts.accounts-service-icon = ''
            mkdir -p /var/lib/AccountsService/icons
            cp ${profileImg} /var/lib/AccountsService/icons/${username}
            chmod 644 /var/lib/AccountsService/icons/${username}
        '';

        # Allow chromium-based apps to run on wayland
        environment.sessionVariables.NIXOS_OZONE_WL = "1";

        # Persist gnome directories
        environment.persistence."/persistent" = {
            hideMounts = true;

            directories = [
                "/var/lib/AccountsService"
            ];

            users.${username}.directories = [
                ".config/dconf"
                ".local/share/gnome-shell"
                ".local/share/gvfs-metadata"
                ".local/share/applications"
                ".local/share/nautilus"
            ];
        };
    }
