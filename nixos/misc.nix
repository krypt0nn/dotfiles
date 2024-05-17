{ ... }: {
    networking = {
        hostName = "observer-pc";

        networkmanager.enable = true;
    };

    time.timeZone = "Europe/Kaliningrad";

    i18n.defaultLocale = "en_US.UTF-8";

    services.xserver = {
        layout = "us,ru";
    };
}
