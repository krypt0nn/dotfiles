{ pkgs, ... }: {
    # Enable GNOME DE
    services.xserver = {
        enable = true;

        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;

        videoDrivers = [ "amdgpu" ];
    };

    # Add some default apps
    environment.systemPackages = with pkgs; [
        ptyxis
        mission-center
        gnome-extension-manager
        loupe
        amberol
        vlc
        papers

        # Setup GNOME extensions
        gnomeExtensions.appindicator
        gnomeExtensions.blur-my-shell
        gnomeExtensions.night-theme-switcher
        gnomeExtensions.caffeine
    ];

    # Remove unneeded built-in gnome apps
    environment.gnome.excludePackages = with pkgs; [
        cheese eog epiphany simple-scan totem yelp geary evince
        gnome-calendar gnome-characters gnome-contacts
        gnome-font-viewer gnome-logs gnome-maps gnome-music
        gnome-system-monitor gnome-connections
        gnome-tour snapshot gnome-console
        # gnome-shell-extensions
    ];

    # Remove XTerm
    services.xserver.excludePackages = [ pkgs.xterm ];

    # Allow chromium-based apps to run on wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
