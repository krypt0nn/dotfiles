{ flakeConfig, lib, pkgs, ... }: {
    networking = {
        # Firewall settings
        firewall = {
            enable = true;

            allowedTCPPorts = [
                # Torrent client
                51413

                # Baldur's Gate 3
                # 27015 27036
            ];

            allowedUDPPorts = [
                # Torrent client
                51413

                # Baldur's Gate 3
                # 27015
            ];

            allowedUDPPortRanges = [
                # Baldur's Gate 3
                # { from = 27031; to = 27036; }
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

        # System-wide proxy
        proxy = lib.attrsets.optionalAttrs flakeConfig.network.global_proxy {
            default = "https://127.0.0.1:9050";
            noProxy = "127.0.0.1,::1,localhost,.localdomain";
        };
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
                # Sep 29, 2024 | avg ping: 39 ms
                # Oct 04, 2024 | avg ping: 33 ms
                "obfs4 51.91.145.55:43695 FC16ACBD3DF13A99728892818ADAD0E0B24B9651 cert=OFqWfnJddrEZivZjzuaru55TPyOPyvaE/Z4msTd3lNg7WY/PwzbrPJB4cVjfg4kMlSORYw iat-mode=0"

                # Sep 18, 2024 | avg ping: 40 ms
                # Sep 21, 2024 | avg ping: 39 ms
                # Sep 29, 2024 | avg ping: 39 ms
                # Oct 04, 2024 | avg ping: 39 ms
                "obfs4 185.177.207.219:11219 598326DF0E32A1E1CCA87A10C9F614C104DD9DE9 cert=QJNjvqxkejHYUuMkM/cQmyV4Egj8S+f+7F4CPxcoWitFEsyP2dJXNQl8jU/M+5v9NeH4Hw iat-mode=1"

                # Oct 04, 2024 | avg ping: 41 ms
                "obfs4 141.95.174.184:16384 10492627B7EE89FCB5E79AC2E6C7BFC74FDACAFA cert=pQ9ZvrzLVLgvKcg+jRTAPoQzrPWfHhw8EnYV47/gTA6nTbfemATndD1xaaa7RCFkC5WHPQ iat-mode=0"

                # Aug 10, 2024 | avg ping: 39 ms
                # Aug 18, 2024 | avg ping: 96 ms
                # Aug 25, 2024 | avg ping: 38 ms
                # Sep 01, 2024 | avg ping: 37 ms
                # Sep 08, 2024 | avg ping: 38 ms
                # Sep 15, 2024 | avg ping: 46 ms
                # Sep 21, 2024 | avg ping: 38 ms
                # Sep 29, 2024 | avg ping: 37 ms
                # Oct 04, 2024 | avg ping: 45 ms
                "obfs4 37.228.129.80:2056 B9A0ABC85F8FDECD3D73F8252A73C4BB22AAD3BD cert=I+5neLvuWJWl6NId2yvwo1sFqgthuIeYAtQY+q6I0mVz3ITLPo9AP35f8WJQsS8o2g5EOw iat-mode=0"

                # Sep 29, 2024 | avg ping: 41 ms
                # Oct 04, 2024 | avg ping: 49 ms
                "obfs4 141.94.213.152:36694 535FE2DAE428D8CF2A354634450F8FD91D5FD8F2 cert=P69epqiL3eztEj5whV/aG/SMgJxTu+2fv0u/7mq1nFNKyTgg3+WR8I47GVpQSSfZyIPteg iat-mode=0"

                # Aug 18, 2024 | avg ping: 146 ms
                # Aug 25, 2024 | avg ping: 61 ms
                # Sep 01, 2024 | avg ping: 60 ms
                # Sep 08, 2024 | avg ping: 62 ms
                # Sep 15, 2024 | avg ping: 80 ms
                # Sep 21, 2024 | avg ping: 61 ms
                # Sep 29, 2024 | avg ping: 61 ms
                # Oct 04, 2024 | avg ping: 60 ms
                "obfs4 95.217.232.211:443 F32A7CD5589CCD2D700D790AB437DE8A6233372C cert=eqAb4zUDdQpKX9TFEuC/x82tiRjvlXkF/WnKxjjSuboPUB3URAwaXcn7m2GIzS8Kd2LDOQ iat-mode=0"

                # Oct 04, 2024 | avg ping: 62 ms
                "obfs4 145.239.30.111:10198 3331738E8BF5162C006F085376FACAC0842054C2 cert=LTh7QyjRDTqMH1Zr9PmKkd6uYz+GeHdfWP9KontJWarQL7B7U6tIWwczPJsu22WiO6qLUg iat-mode=0"

                # Sep 08, 2024 | avg ping: 38 ms
                # Sep 15, 2024 | avg ping: 41 ms
                # Sep 21, 2024 | avg ping: 37 ms
                # Sep 29, 2024 | avg ping: 61 ms
                # Oct 04, 2024 | avg ping: 76 ms
                "obfs4 79.137.11.195:56288 CDAA4933BE540D25CF8F391E23F9A4861ACB5F4C cert=EicEZ20+CMP7iwmwgVujZOCtZHyIikzAmQOxrjAF2khU+IMm9iVN/tMDlYtoHSeCj11bVQ iat-mode=0"
            ];

            DNSPort = [
                {
                    addr = "127.0.0.1";
                    port = 53;
                }
            ];

            CookieAuthentication = true;
            HardwareAccel = 1;
            ClientOnly = 1;
            ClientUseIPv6 = true;
        };
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
