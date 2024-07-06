{ ... }: {
    # Enable automatic CPU frequency configuration
    services.auto-cpufreq = {
        enable = true;

        settings = {
            battery = {
                governor = "powersave";
                turbo = "never";
            };

            charger = {
                governor = "performance";
                turbo = "auto";
            };
        };
    };

    # Enable weekly SSD TRIM service (SSD optimization)
    services.fstrim.enable = true;

    # Enable weekly firmware updates service
    services.fwupd.enable = true;
}
