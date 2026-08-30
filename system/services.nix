{ ... }: {
    # Enable weekly SSD TRIM service.
    services.fstrim.enable = true;

    # Enable firmware updates.
    services.fwupd.enable = true;

    # Load balancer.
    services.irqbalance.enable = true;

    # Ban connections after failed login attempts.
    services.fail2ban.enable = true;

    # Disks management service.
    services.udisks2.enable = true;

    # Don't write journald logs to disk.
    # https://news.ycombinator.com/item?id=49290215
    services.journald = {
        storage = "volatile";
        extraConfig = "MaxRetentionSec=1day";
    };

    # Persist services folders.
    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/var/lib/fwupd"
            "/var/cache/fwupd"
            "/var/lib/fail2ban"
            "/var/lib/udisks2"
        ];
    };
}
