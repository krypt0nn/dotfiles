{ pkgs, ... }: {
    networking = {
        # Firewall settings
        firewall = {
            enable = true;

            allowedTCPPorts = [
                # Torrent client
                51413
            ];

            allowedUDPPorts = [
                # Torrent client
                51413

                # Minecraft Plasmo Voice
                25565
            ];
        };

        # Configure networking
        networkmanager = {
            enable = true;
            dns = "systemd-resolved";
        };

        # Setup hosts file
        hosts = {
            # Block telemetry servers
            "0.0.0.0" = [
                # Wuthering Waves
                "pc.crashsight.wetest.net"

                # Hoyoverse games
                "log-upload-os.hoyoverse.com"
                "overseauspider.yuanshen.com"
                "sg-public-data-api.hoyoverse.com"
            ];
        };

        # DNS nameservers
        nameservers = [
            # Tailscale MagicDNS
            "100.100.100.100"

            # Local DNS
            "127.0.0.1"
            "::1"

            # Cloudflare DNS
            # "1.1.1.1"
            # "1.0.0.1"
            # "2606:4700:4700::1111"
            # "2606:4700:4700::1001"

            # Yandex DNS
            # "77.88.8.88"
            # "77.88.8.2"
            # "2a02:6b8::feed:bad"
            # "2a02:6b8:0:1::feed:bad"
        ];
    };

    # SystemD DNS resolving service
    # Will be spawned under 127.0.0.53 address
    services.resolved = {
        # Enable DNS queries caching
        enable = true;

        fallbackDns = [
            # Tailscale MagicDNS
            "100.100.100.100"

            # Local DNS
            "127.0.0.1"
            "::1"
        ];
    };

    # Tailscale
    services.tailscale.enable = true;

    # Tor
    services.tor = {
        enable = true;

        client = {
            # SOCKS5 proxy
            enable = true;

            # Local DNS
            dns.enable = true;
        };

        settings = {
            UseBridges = true;
            ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";

            Bridge = [
                "obfs4 83.226.191.248:2048 6FEC97F7437D5451211B42F35784FC2A436C2610 cert=3ubRj29BI4QtyMOVI/XiIE8tNTIypFqj5FtAtSnqMSdNu2ot43UL8PJ4U2c+asMV8YjZeA iat-mode=0"
                "obfs4 150.43.248.236:443 E69FD1828D270D6F7DD94B1B2C5261CBF1A32583 cert=o3UL0xikRiafXXdnzXC3puRCDEaN7cRhwu+/0VnTcyVIgxFmg/Ds+LEGx2lKS/U7lYGLHQ iat-mode=0"
                "obfs4 148.113.142.109:19611 04146098FCBC06D60B1399F6FDE0A1B7BC32BEDB cert=Pp8Xs7TuckTJovwGFlBfZ1tV+4fx6zzmyvuvf4M5EpcC7OOrAgyVVr8GgKOk2qP/Hi0YOQ iat-mode=0"
                "obfs4 141.94.212.150:45891 5FEE9747D104A7ED8CBA5485C460A9E007C50242 cert=BW6HwBPzw1GJJUyyrxoSfQwMPuyX5+nxv1s61ix+Y0bwxVIXT9avlwT1X0gew1bMP3BjCw iat-mode=0"
            ];

            DNSPort = [
                {
                    addr = "0.0.0.0";
                    port = 53;
                }
            ];

            Address = "0.0.0.0";
            HTTPTunnelPort = 10050;

            CookieAuthentication = true;
            HardwareAccel = 1;
            ClientOnly = 1;
            ClientUseIPv6 = true;
        };
    };

    # Xray proxy
    services.xray = {
        enable = true;

        settingsFile = "/persistent/xray.jsonc";
    };

    # Persist folders
    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            { directory = "/var/lib/tailscale"; mode = "0700"; }
            { directory = "/var/lib/tor"; mode = "0700"; }
        ];
    };
}
