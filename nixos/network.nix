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
        # Cloudflare DNS
        # "1.1.1.1"
        # "1.0.0.1"
        # "2606:4700:4700::1111"
        # "2606:4700:4700::1001"

        # Yandex DNS
        "77.88.8.88"
        "77.88.8.2"
        "2a02:6b8::feed:bad"
        "2a02:6b8:0:1::feed:bad"
    ];
}
