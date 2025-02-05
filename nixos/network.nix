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
                "obfs4 109.173.237.19:12112 FA172EE8983E36D1AC931DB3EF7316AF6CFA4A41 cert=BVWMhIUZxiTNNBHh5daNeI9KUetMXUiVfeqIVjJTgTwkZl2dUSLFOPeW62suuTvI42IAbQ iat-mode=0"
                "obfs4 91.134.102.250:9148 CEA13B444B66CFCCF34D9C39F9D5CE5E80450450 cert=FU/0w4FoA8c7CjeoyaW7WvgEDAbDr/5PC8R6+MrzIQlwRF1EpGEzYYYQsZVmCIOD4a2aSw iat-mode=0"
                "obfs4 57.128.122.84:3717 08244D7E8D504E92C94265C3EB3EA85DC97A039F cert=gwqScddnxBPuzl8GvH+//j5Sduq+zpuaYpHBnDHi/vyAzspjBFjzZiC4fT8WM3MgRkZyWA iat-mode=0"
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
