{ flakeConfig, pkgs, ... }: {
    # DNS
    networking = {
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

        # Fallback to blocky DNS
        fallbackDns = [
            "127.0.0.1"
            "::1"
        ];
    };

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
                # Aug 10, 2024 | avg ping: 40 ms
                # Aug 18, 2024 | avg ping: 44 ms
                "obfs4 193.70.74.188:9831 23817363721D5DD71B658F37EE6D92F89B90E06B cert=jjWFUtbXZlygVFbVOUwLc1Ipdg0H/iiMEAHGOcWv2z6+UTiHoySvtxgvfbnMPLBmh2CvcQ iat-mode=0"

                # Aug 1, 2024  | avg ping: 36 ms
                # Aug 10, 2024 | avg ping: 35 ms
                # Aug 18, 2024 | avg ping: 53 ms
                "obfs4 95.179.181.148:3479 59A5D54882C6ADEA6E1F9B9ED508479475BFBDCA cert=xX+mvC/OWERv0oZXF6SemAOnXSmujQeP2IhNew3cSskyeZmhqnsaGHBDSw1XEGRkrvH2MA iat-mode=0"

                # Aug 10, 2024 | avg ping: 39 ms
                # Aug 18, 2024 | avg ping: 96 ms
                "obfs4 37.228.129.80:2056 B9A0ABC85F8FDECD3D73F8252A73C4BB22AAD3BD cert=I+5neLvuWJWl6NId2yvwo1sFqgthuIeYAtQY+q6I0mVz3ITLPo9AP35f8WJQsS8o2g5EOw iat-mode=0"

                # Aug 1, 2024  | avg ping: 46 ms
                # Aug 10, 2024 | avg ping: 33 ms
                # Aug 18, 2024 | avg ping: 116 ms
                "obfs4 51.91.211.22:30314 EB58799CC45EE3430DF20112D7BAED05BBD4CCD4 cert=3kGMw/fAF+Lk8z1mpuNtULveQITOp4yMDnDTIXwmK4jiN6pqDrK3239nzGXSM1XLctT2cA iat-mode=0"

                # Aug 18, 2024 | avg ping: 146 ms
                "obfs4 95.217.232.211:443 F32A7CD5589CCD2D700D790AB437DE8A6233372C cert=eqAb4zUDdQpKX9TFEuC/x82tiRjvlXkF/WnKxjjSuboPUB3URAwaXcn7m2GIzS8Kd2LDOQ iat-mode=0"

                # Aug 10, 2024 | avg ping: 45 ms
                # Aug 18, 2024 | avg ping: 149 ms
                "obfs4 51.83.225.13:7137 064806FB24FDBF68139A716A638E33A5CBDE5F8B cert=gaIPYNWkt6gM1DU9UbLiH1XJw2qWe2jMcUyBebEfiI+LFRrQKeTccata7MG2yIb3ee7/cw iat-mode=0"

                # Aug 1, 2024  | avg ping: 41 ms
                # Aug 10, 2024 | avg ping: 40 ms
                # Aug 18, 2024 | avg ping: 191 ms
                "obfs4 79.137.11.77:56490 A95B850794AC06841FB93F32AD3C997FA8836E52 cert=C+Xz1PxmruAyp9uehauc9u+l+RJG6cZ3x+l3qMJaejVy8iJDTxqi6uOvTxFlrnJL/bMXcg iat-mode=0"
            ];

            DNSPort = [
                {
                    addr = "127.0.0.1";
                    port = 53;
                }
            ];

            CookieAuthentication = true;
            HardwareAccel = 1;
        };
    };
}
