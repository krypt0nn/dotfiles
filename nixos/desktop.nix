{ config, lib, pkgs, pkgs-unstable, ... }: {
    # Enable GNOME DE
    services.xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
        videoDrivers = [ "amdgpu" ];
    };

    # Add some default apps
    environment.systemPackages = with pkgs; [
        blackbox-terminal
        mission-center
        gnome-extension-manager
        loupe
        vlc
        papers

        # TODO: change to stable as soon as it becomes available
        pkgs-unstable.decibels

        # Setup GNOME extensions
        gnomeExtensions.appindicator
        gnomeExtensions.blur-my-shell
        gnomeExtensions.night-theme-switcher
        gnomeExtensions.caffeine
    ];

    # Remove unneeded built-in gnome apps
    environment.gnome.excludePackages = with pkgs.gnome; [
        cheese eog epiphany simple-scan totem yelp geary evince
        gnome-calendar gnome-characters gnome-contacts
        gnome-font-viewer gnome-logs gnome-maps gnome-music
        gnome-system-monitor pkgs.gnome-connections
        pkgs.gnome-tour pkgs.snapshot pkgs.gnome-console
        # gnome-shell-extensions
    ];

    # Remove XTerm
    services.xserver.excludePackages = [ pkgs.xterm ];

    # Allow chromium-based apps to run on wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
