{ ... }: {
    networking.hosts = {
        # Block telemetry servers
        "0.0.0.0" = [
            # Wuthering Waves
            "pc.crashsight.wetest.net"
        ];
    };

    # Cloudflare DNS
    # networking.nameservers = [
    #     "1.1.1.1"
    #     "1.0.0.1"
    # ];
}
