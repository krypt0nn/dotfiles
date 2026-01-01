{ ... }: {
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

    services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
    };

    services.fail2ban.enable = true;
}
