{ ... }: {
    networking.firewall.allowedTCPPorts = [
        # Tor services
        53 9050 10050
    ];
}
