{ ... }: {
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Kaliningrad";

    i18n.defaultLocale = "en_US.UTF-8";

    # NixOS 23.11
    services.xserver.layout = "us,ru";

    # NixOS 24.05
    # services.xserver.xkb.layout = "us,ru";
}
