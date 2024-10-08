{ flakeConfig, lib, pkgs, pkgs-unstable, ... }: {
    networking = {
        # Firewall settings
        firewall = {
            enable = true;

            allowedTCPPorts = [
                # Tor socket
                9050

                # SpoofDPI socket
                10050
            ];
        };

        # Configure networking
        networkmanager = {
            enable = true;
            dns = "systemd-resolved";
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
        # proxy = {
        #     default = "https://observer-server:10050";
        #     noProxy = "127.0.0.1,::1,localhost,.localdomain";
        # };
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
    services.tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = "server";
    };

    services.networkd-dispatcher = {
        enable = true;

        rules."50-tailscale" = {
            onState = [ "routable" ];
            script = "${lib.getExe pkgs.ethtool} -K eth0 rx-udp-gro-forwarding on rx-gro-list off";
        };
    };

    # SpoofDPI
    systemd.services.spoofdpi = {
        description = "Start local SpoofDPI proxy on port 10050.";

        wantedBy = [ "default.target" ];

        script = "${pkgs-unstable.spoofdpi}/bin/spoofdpi -dns-addr 127.0.0.53 -addr observer-server -port 10050";
    };

    # Tor
    services.tor = {
        enable = true;

        client = {
            # SOCKS5 proxy
            enable = true;

            socksListenAddress = {
                IsolateDestAddr = true;

                addr = "observer-server";
                port = 9050;
            };

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

                # Oct 07, 2024 | avg ping: 41 ms
                "obfs4 85.215.50.238:10007 D27430CDF128406ED556434E8F908749EE6D0198 cert=GBiBNfVY/4VSWG6Qx7HmsPMB6WAq80HIr8JUUkTdxsk2L5QdrjdZap8WjyrpaizU58SQGA iat-mode=0"

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

                # Oct 07, 2024 | avg ping: 52 ms
                "obfs4 51.195.233.64:63542 06FA323EBE816B9DD68CA1561851C28009BD7906 cert=KD/MpxM0IWkugg4fKV2HhQZg6sDLbQfEVAqxlel+4aA0rudHUkUX1165dxUlzNVnBAHQQA iat-mode=0"

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

                # Oct 07, 2024 | avg ping: 62 ms
                "obfs4 94.156.153.217:31337 AF9EABB157AE185E3D0F030D6F21C2044A794976 cert=Gg+YPaGTlB30p7x45igqEJQ4Af/8HqgbIzwJ1GBzqto1xSDS/k5H83mttmUh0Zob+vrQWw iat-mode=0"
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
