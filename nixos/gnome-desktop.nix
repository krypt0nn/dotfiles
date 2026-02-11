{ pkgs, ... }: {
    # Enable GNOME DE
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Add some default apps
    environment.systemPackages = with pkgs; [
        mission-center
        gnome-extension-manager
        loupe
        vlc
        file-roller

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
        # gnome-shell-extensions
    ];

    # Remove XTerm
    services.xserver.excludePackages = [ pkgs.xterm ];

    # Enable gnome QT theme
    qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita";
    };

    # Allow chromium-based apps to run on wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
