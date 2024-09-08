{ flakeConfig, lib, pkgs, ... }: {
    networking = {
        # Firewall settings
        firewall = {
            enable = true;

            allowedTCPPorts = [
                # Default services ports
                22 80 443

                # Torrent client
                51413

                # Baldur's Gate 3
                27015 27036
            ];

            allowedUDPPorts = [
                # Torrent client
                51413

                # Baldur's Gate 3
                27015
            ];

            allowedUDPPortRanges = [
                # Baldur's Gate 3
                { from = 27031; to = 27036; }
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
                # Aug 01, 2024 | avg ping: 46 ms
                # Aug 10, 2024 | avg ping: 33 ms
                # Aug 18, 2024 | avg ping: 116 ms
                # Aug 25, 2024 | avg ping: 32 ms
                # Sep 01, 2024 | avg ping: 32 ms
                # Sep 08, 2024 | avg ping: 32 ms
                "obfs4 51.91.211.22:30314 EB58799CC45EE3430DF20112D7BAED05BBD4CCD4 cert=3kGMw/fAF+Lk8z1mpuNtULveQITOp4yMDnDTIXwmK4jiN6pqDrK3239nzGXSM1XLctT2cA iat-mode=0"

                # Aug 10, 2024 | avg ping: 39 ms
                # Aug 18, 2024 | avg ping: 96 ms
                # Aug 25, 2024 | avg ping: 38 ms
                # Sep 01, 2024 | avg ping: 37 ms
                # Sep 08, 2024 | avg ping: 38 ms
                "obfs4 37.228.129.80:2056 B9A0ABC85F8FDECD3D73F8252A73C4BB22AAD3BD cert=I+5neLvuWJWl6NId2yvwo1sFqgthuIeYAtQY+q6I0mVz3ITLPo9AP35f8WJQsS8o2g5EOw iat-mode=0"

                # Sep 08, 2024 | avg ping: 38 ms
                "obfs4 79.137.11.195:56288 CDAA4933BE540D25CF8F391E23F9A4861ACB5F4C cert=EicEZ20+CMP7iwmwgVujZOCtZHyIikzAmQOxrjAF2khU+IMm9iVN/tMDlYtoHSeCj11bVQ iat-mode=0"

                # Aug 25, 2024 | avg ping: 92 ms
                # Sep 01, 2024 | avg ping: 39 ms (stopped working?)
                # Sep 08, 2024 | avg ping: 40 ms
                "obfs4 130.255.76.46:9098 9B72F502756CDDD28966931B2C1296259DD57780 cert=xNYGvoaiALC4RCCDmkZfYApBHXK+IUBWfqc62QgPVrJo7qer3YUAv1tSYl1ozHEdId4Kfw iat-mode=0"

                # Aug 25, 2024 | avg ping: 44 ms
                # Sep 01, 2024 | avg ping: 44 ms
                # Sep 08, 2024 | avg ping: 44 ms
                "obfs4 51.77.108.19:38048 C9190FBF5CE8D3A9CB5EF7B0FA3639A363DD0934 cert=thUg/P0x/IFk2d//p2iu5UPM4wK9ko9myJw4MB2nZ6A6tbjmXxQEiorMm373gUGh8iF6Vw iat-mode=0"

                # Aug 22, 2024 | avg ping: 51 ms
                # Aug 25, 2024 | avg ping: 96 ms
                # Sep 01, 2024 | avg ping: 49 ms
                # Sep 08, 2024 | avg ping: 48 ms
                "obfs4 82.165.190.146:9443 4E2353218AB9DB222A7686A0E23A53358444641F cert=oWFrOozg/SFBcbk/09n6TIgzEe3TBmeiIlyPTMG/7iqwyUOPhSkpDRYQ16MaigMAxyL4HA iat-mode=0"

                # Aug 01, 2024 | avg ping: 36 ms
                # Aug 10, 2024 | avg ping: 35 ms
                # Aug 18, 2024 | avg ping: 53 ms
                # Aug 25, 2024 | avg ping: 51 ms
                # Sep 01, 2024 | avg ping: 51 ms (stopped working?)
                # Sep 08, 2024 | avg ping: 55 ms
                "obfs4 95.179.181.148:3479 59A5D54882C6ADEA6E1F9B9ED508479475BFBDCA cert=xX+mvC/OWERv0oZXF6SemAOnXSmujQeP2IhNew3cSskyeZmhqnsaGHBDSw1XEGRkrvH2MA iat-mode=0"

                # Sep 08, 2024 | avg ping: 54 ms
                "obfs4 92.252.89.222:8080 02F00A33017A24E99112E5CA498AECD204F913F3 cert=eWfCYOE/3kdmDpYy/tT0CuKI01dWKY6BtSAMSu0uuD4ixo7RE4/av+0fNjw4sbZmORLKVQ iat-mode=0"

                # Aug 01, 2024 | avg ping: 41 ms
                # Aug 10, 2024 | avg ping: 40 ms
                # Aug 18, 2024 | avg ping: 191 ms
                # Aug 25, 2024 | avg ping: 42 ms
                # Sep 01, 2024 | avg ping: 41 ms (stopped working?)
                # Sep 08, 2024 | avg ping: 58 ms
                "obfs4 79.137.11.77:56490 A95B850794AC06841FB93F32AD3C997FA8836E52 cert=C+Xz1PxmruAyp9uehauc9u+l+RJG6cZ3x+l3qMJaejVy8iJDTxqi6uOvTxFlrnJL/bMXcg iat-mode=0"

                # Aug 10, 2024 | avg ping: 40 ms
                # Aug 18, 2024 | avg ping: 44 ms
                # Aug 25, 2024 | avg ping: 109 ms
                # Sep 01, 2024 | avg ping: 57 ms
                # Sep 08, 2024 | avg ping: 58 ms
                "obfs4 193.70.74.188:9831 23817363721D5DD71B658F37EE6D92F89B90E06B cert=jjWFUtbXZlygVFbVOUwLc1Ipdg0H/iiMEAHGOcWv2z6+UTiHoySvtxgvfbnMPLBmh2CvcQ iat-mode=0"

                # Aug 18, 2024 | avg ping: 146 ms
                # Aug 25, 2024 | avg ping: 61 ms
                # Sep 01, 2024 | avg ping: 60 ms
                # Sep 08, 2024 | avg ping: 62 ms
                "obfs4 95.217.232.211:443 F32A7CD5589CCD2D700D790AB437DE8A6233372C cert=eqAb4zUDdQpKX9TFEuC/x82tiRjvlXkF/WnKxjjSuboPUB3URAwaXcn7m2GIzS8Kd2LDOQ iat-mode=0"

                # Aug 22, 2024 | avg ping: 57 ms
                # Aug 25, 2024 | avg ping: 53 ms
                # Sep 01, 2024 | avg ping: 41 ms
                # Sep 08, 2024 | avg ping: 87 ms
                "obfs4 141.94.209.150:60192 AAB1C871CA4760614BFCB6E94979F83727F905BF cert=C9MjwMKC5MryvrhLpaWWyB/MFTKd2H0kuBfoaPR0Dv9574sfsW+HjsemUepaw3KZ3o+WDA iat-mode=0"
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
        };
    };
}
