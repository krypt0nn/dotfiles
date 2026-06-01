{ ... }: {
    # Enable weekly SSD TRIM service (SSD optimization)
    services.fstrim.enable = true;

    # Enable monthly btrfs data validation service
    services.btrfs.autoScrub.enable = true;

    # Enable weekly firmware updates service
    services.fwupd.enable = true;

    # Load balancer
    services.irqbalance.enable = true;

    # Ban connections after failed login attempts
    services.fail2ban.enable = true;

    # Disks management service.
    services.udisks2.enable = true;

    # Faster dbus implementation
    services.dbus.implementation = "broker";
}
