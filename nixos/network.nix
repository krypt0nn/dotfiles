{ flakeConfig, ... }: {
    networking.hosts = {
        # Block telemetry servers
        "0.0.0.0" = [
            # Wuthering Waves
            "pc.crashsight.wetest.net"

            # Hoyoverse games
            "log-upload-os.hoyoverse.com"
            "overseauspider.yuanshen.com"
        ];
    };

    # Configure networking
    networking.networkmanager.enable = true;

    # DNS nameservers
    networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
    ];
}
