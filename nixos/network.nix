{ flakeConfig, lib, pkgs, pkgs-unstable, ... }: {
    networking = {
        # Firewall settings
        firewall = {
            enable = true;

            allowedTCPPorts = [
                # Torrent client
                51413
            ];

            allowedTCPPortRanges = [
                # Steam
                { from = 27000; to = 27100; }
            ];

            allowedUDPPorts = [
                # Torrent client
                51413
            ];

            allowedUDPPortRanges = [
                # Steam
                { from = 27000; to = 27100; }
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

    # SpoofDPI
    # systemd.services.spoofdpi = {
    #     description = "Local SpoofDPI proxy on port 10050.";

    #     wantedBy = [ "default.target" ];

    #     script = "${pkgs-unstable.spoofdpi}/bin/spoofdpi -dns-addr 127.0.0.53 -addr 0.0.0.0 -port 10050";
    # };

    # ByeDPI
    systemd.services.byedpi = {
        description = "Local ByeDPI proxy on port 11050.";

        wantedBy = [ "default.target" ];

        script = "${pkgs-unstable.byedpi}/bin/ciadpi -a1 -F -s1 -q1 -Y -At -T5 -b1000000 -S -f-1 -r1+sm -As -x1 --ip 0.0.0.0 --port 11050";
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
                # Oct 13, 2024 | avg ping: 43 ms
                # Oct 18, 2024 | avg ping: 60 ms
                # Oct 30, 2024 | avg ping: 38 ms
                "obfs4 37.187.16.190:443 941817DB0A9D6F47ED827CFB4171D2EF7BED5719 cert=fnaW6DGqRNwPeT6F7BiM4bncNyqRXRahMVSxrSkH5+FAMdltO54zPRFxl8naIQQmR3QCcQ iat-mode=0"

                # Oct 18, 2024 | avg ping: 62 ms
                # Oct 30, 2024 | avg ping: 41 ms
                "obfs4 91.134.101.66:50853 7E0EA5CC553C59BB8D7B4542190161C16642B16E cert=dgfs+IzVdnGvjfk+Va2fvuRsQR0Q3bkdBerHXFjSTWkLJF5Oi9oEtaqHFgkjevTfw/zcBw iat-mode=0"

                # Sep 18, 2024 | avg ping: 40 ms
                # Sep 21, 2024 | avg ping: 39 ms
                # Sep 29, 2024 | avg ping: 39 ms
                # Oct 04, 2024 | avg ping: 39 ms
                # Oct 13, 2024 | avg ping: 61 ms
                # Oct 18, 2024 | avg ping: 43 ms
                # Oct 30, 2024 | avg ping: 45 ms
                "obfs4 185.177.207.219:11219 598326DF0E32A1E1CCA87A10C9F614C104DD9DE9 cert=QJNjvqxkejHYUuMkM/cQmyV4Egj8S+f+7F4CPxcoWitFEsyP2dJXNQl8jU/M+5v9NeH4Hw iat-mode=1"

                # Oct 13, 2024 | avg ping: 42 ms
                # Oct 18, 2024 | avg ping: 59 ms
                # Oct 30, 2024 | avg ping: 52 ms
                "obfs4 91.134.101.66:50853 7E0EA5CC553C59BB8D7B4542190161C16642B16E cert=dgfs+IzVdnGvjfk+Va2fvuRsQR0Q3bkdBerHXFjSTWkLJF5Oi9oEtaqHFgkjevTfw/zcBw iat-mode=0"

                # Aug 10, 2024 | avg ping: 39 ms
                # Aug 18, 2024 | avg ping: 96 ms
                # Aug 25, 2024 | avg ping: 38 ms
                # Sep 01, 2024 | avg ping: 37 ms
                # Sep 08, 2024 | avg ping: 38 ms
                # Sep 15, 2024 | avg ping: 46 ms
                # Sep 21, 2024 | avg ping: 38 ms
                # Sep 29, 2024 | avg ping: 37 ms
                # Oct 04, 2024 | avg ping: 45 ms
                # Oct 13, 2024 | avg ping: 37 ms
                # Oct 18, 2024 | avg ping: 37 ms
                # Oct 30, 2024 | avg ping: 55 ms
                "obfs4 37.228.129.80:2056 B9A0ABC85F8FDECD3D73F8252A73C4BB22AAD3BD cert=I+5neLvuWJWl6NId2yvwo1sFqgthuIeYAtQY+q6I0mVz3ITLPo9AP35f8WJQsS8o2g5EOw iat-mode=0"

                # Oct 07, 2024 | avg ping: 62 ms
                # Oct 13, 2024 | avg ping: 79 ms
                # Oct 18, 2024 | avg ping: 61 ms
                # Oct 30, 2024 | avg ping: 55 ms
                "obfs4 94.156.153.217:31337 AF9EABB157AE185E3D0F030D6F21C2044A794976 cert=Gg+YPaGTlB30p7x45igqEJQ4Af/8HqgbIzwJ1GBzqto1xSDS/k5H83mttmUh0Zob+vrQWw iat-mode=0"

                # Oct 07, 2024 | avg ping: 41 ms
                # Oct 13, 2024 | avg ping: 40 ms
                # Oct 18, 2024 | avg ping: 40 ms
                # Oct 30, 2024 | avg ping: 58 ms
                "obfs4 85.215.50.238:10007 D27430CDF128406ED556434E8F908749EE6D0198 cert=GBiBNfVY/4VSWG6Qx7HmsPMB6WAq80HIr8JUUkTdxsk2L5QdrjdZap8WjyrpaizU58SQGA iat-mode=0"

                # Aug 18, 2024 | avg ping: 146 ms
                # Aug 25, 2024 | avg ping: 61 ms
                # Sep 01, 2024 | avg ping: 60 ms
                # Sep 08, 2024 | avg ping: 62 ms
                # Sep 15, 2024 | avg ping: 80 ms
                # Sep 21, 2024 | avg ping: 61 ms
                # Sep 29, 2024 | avg ping: 61 ms
                # Oct 04, 2024 | avg ping: 60 ms
                # Oct 13, 2024 | avg ping: 61 ms
                # Oct 18, 2024 | avg ping: 61 ms
                # Oct 30, 2024 | avg ping: 61 ms
                "obfs4 95.217.232.211:443 F32A7CD5589CCD2D700D790AB437DE8A6233372C cert=eqAb4zUDdQpKX9TFEuC/x82tiRjvlXkF/WnKxjjSuboPUB3URAwaXcn7m2GIzS8Kd2LDOQ iat-mode=0"

                # Oct 18, 2024 | avg ping: 35 ms
                # Oct 30, 2024 | avg ping: 69 ms
                "obfs4 54.36.119.132:35979 AD1C598EDD83206F84402EEC6994F393A2649FF7 cert=cDQkdcaXhe8RHl0/QcNLG4rjau6XRbo2l2dicQP/s3vsn1AcSmizwX5tLKgphzqFCxStDg iat-mode=0"
            ];

            DNSPort = [
                {
                    addr = "127.0.0.1";
                    port = 53;
                }
            ];

            HTTPTunnelPort = 10050;

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
