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
            noProxy = "127.0.0.1,localhost,.localdomain";
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
                # Sep 15, 2024 | avg ping: 39 ms
                "obfs4 37.59.25.181:29665 5755820AFDEB3149AC6F2FF6C558B3D335874C47 cert=jnjwkoZXFtB3UZnAmnTDQ+VyBteqrSBHn3xwZYvDHbJAsVldXxWp30TgezsPHWaekoQZag iat-mode=0"

                # Sep 08, 2024 | avg ping: 38 ms
                # Sep 15, 2024 | avg ping: 41 ms
                "obfs4 79.137.11.195:56288 CDAA4933BE540D25CF8F391E23F9A4861ACB5F4C cert=EicEZ20+CMP7iwmwgVujZOCtZHyIikzAmQOxrjAF2khU+IMm9iVN/tMDlYtoHSeCj11bVQ iat-mode=0"

                # Aug 10, 2024 | avg ping: 39 ms
                # Aug 18, 2024 | avg ping: 96 ms
                # Aug 25, 2024 | avg ping: 38 ms
                # Sep 01, 2024 | avg ping: 37 ms
                # Sep 08, 2024 | avg ping: 38 ms
                # Sep 15, 2024 | avg ping: 46 ms
                "obfs4 37.228.129.80:2056 B9A0ABC85F8FDECD3D73F8252A73C4BB22AAD3BD cert=I+5neLvuWJWl6NId2yvwo1sFqgthuIeYAtQY+q6I0mVz3ITLPo9AP35f8WJQsS8o2g5EOw iat-mode=0"

                # Sep 15, 2024 | avg ping: 49 ms
                "obfs4 141.95.109.65:45241 9AB77274A9BBA67451C3BAB1D965E5EA7DACCC54 cert=2GeuOgydh+4ledJQbGFcI+YZ9+9OoFbLz9WHwM6fpbopuTT2JK4WkCQG2eM1grgkKvJcQQ iat-mode=0"

                # Sep 16, 2024 | avg ping: 64 ms
                "obfs4 51.77.111.182:49885 55414CB64AD283F7FBEB9643EBCB7E3A67ECB115 cert=+ZblXK36ALspn481jpywY0GgbPpbD6jF7ExE2+tQWYVkXfUP2P5f9jpornJWGh+jTSb/cg iat-mode=0"

                # Aug 18, 2024 | avg ping: 146 ms
                # Aug 25, 2024 | avg ping: 61 ms
                # Sep 01, 2024 | avg ping: 60 ms
                # Sep 08, 2024 | avg ping: 62 ms
                # Sep 15, 2024 | avg ping: 80 ms
                "obfs4 95.217.232.211:443 F32A7CD5589CCD2D700D790AB437DE8A6233372C cert=eqAb4zUDdQpKX9TFEuC/x82tiRjvlXkF/WnKxjjSuboPUB3URAwaXcn7m2GIzS8Kd2LDOQ iat-mode=0"

                # Aug 22, 2024 | avg ping: 51 ms
                # Aug 25, 2024 | avg ping: 96 ms
                # Sep 01, 2024 | avg ping: 49 ms
                # Sep 08, 2024 | avg ping: 48 ms
                # Sep 15, 2024 | avg ping: 105 ms
                "obfs4 82.165.190.146:9443 4E2353218AB9DB222A7686A0E23A53358444641F cert=oWFrOozg/SFBcbk/09n6TIgzEe3TBmeiIlyPTMG/7iqwyUOPhSkpDRYQ16MaigMAxyL4HA iat-mode=0"

                # Sep 16, 2024 | avg ping: 118 ms
                "obfs4 148.113.141.237:15896 DA6D9EBFE447409A65CBB374BAB1FF2E4F8B87E2 cert=QpHxGej6p19e2Glh8m7Vbm2bBkG9D0+VOw73Js858QMHauI8zu5F8TWcuU6FxJY2XItrbw iat-mode=0"
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
            ClientUseIPv6 = 1;
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
