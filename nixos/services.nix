{ ... }: {
    # Enable automatic CPU frequency configuration
    # Disabled now because I use GNOME Power Manager deamon
    # which interfer with this service and prevents it normal work

    # services.auto-cpufreq = {
    #     enable = true;

    #     settings = {
    #         battery = {
    #             governor = "powersave";
    #             turbo = "never";
    #         };

    #         charger = {
    #             governor = "performance";
    #             turbo = "auto";
    #         };
    #     };
    # };

    # Control cooling depending on the system temperature
    services.thermald.enable = true;

    # Enable weekly SSD TRIM service (SSD optimization)
    services.fstrim.enable = true;

    # Enable monthly btrfs data validation service
    services.btrfs.autoScrub.enable = true;

    # Enable weekly firmware updates service
    services.fwupd.enable = true;

    # Faster dbus implementation
    services.dbus.implementation = "broker";

    # Load balancer
    services.irqbalance.enable = true;

    # Ban connections after failed login attempts
    services.fail2ban.enable = true;
}
