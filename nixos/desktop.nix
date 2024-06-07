{ config, lib, pkgs, ... }: {
    # Enable GNOME DE
    services.xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
    };

    # Add some default apps
    environment.systemPackages = with pkgs; [
        blackbox-terminal
        gnome-extension-manager
        loupe
        resources
    ];

    # Remove unneeded built-in gnome apps
    environment.gnome.excludePackages = with pkgs.gnome; [
        cheese eog epiphany simple-scan
        totem yelp evince geary file-roller
        gnome-calendar gnome-characters gnome-contacts
        gnome-font-viewer gnome-logs gnome-maps gnome-music
        gnome-system-monitor pkgs.gnome-connections
        pkgs.gnome-tour pkgs.snapshot pkgs.gnome-console
        # gnome-shell-extensions
    ];

    # Remove XTerm
    services.xserver.excludePackages = [ pkgs.xterm ];
}
