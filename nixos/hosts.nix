{ ... }: {
    networking.hosts = {
        # Block telemetry servers
        "0.0.0.0" = [
            # Wuthering Waves
            "pc.crashsight.wetest.net"
        ];
    };
}
