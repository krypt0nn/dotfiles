{ pkgs, ... }: {
    networking = {
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

                # Factorio
                34197
                53747
            ];
        };

        networkmanager = {
            enable = true;
            dns = "none";
        };

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

        nameservers = [
            "127.0.0.1"
            "::1"
        ];
    };

    # Tailscale
    services.tailscale = {
        enable = true;
        extraUpFlags = [ "--accept-dns=false" ];
    };

    # Blocky
    services.blocky = {
        enable = true;

        settings = {
            ports.dns = 53;

            upstreams.groups.default = [
                "https://one.one.one.one/dns-query"
            ];

            bootstrapDns = {
                upstream = "https://one.one.one.one/dns-query";

                ips = [
                    "1.1.1.1"
                    "1.0.0.1"
                    "2606:4700:4700::1111"
                    "2606:4700:4700::1001"
                ];
            };

            blocking = {
                denylists = {
                    ads = [
                        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
                    ];

                    trackers = [
                        # "https://raw.githubusercontent.com/InAUGral/pihole-blocklist-gametrackers/main/pihole-blocklist-gametrackers.txt"
                        "https://blocklistproject.github.io/Lists/tracking.txt"
                    ];
                };

                clientGroupsBlock.default = [
                    "ads"
                    "trackers"
                ];
            };

            caching = {
                prefetching = true;
                prefetchExpires = "16h";
                prefetchThreshold = 3;
                minTime = "5m";
            };
        };
    };

    # Tor
    services.tor = {
        enable = true;
        client.enable = true;

        settings = {
            UseBridges = true;
            ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";

            Bridge = [
                "obfs4 150.43.248.236:443 E69FD1828D270D6F7DD94B1B2C5261CBF1A32583 cert=o3UL0xikRiafXXdnzXC3puRCDEaN7cRhwu+/0VnTcyVIgxFmg/Ds+LEGx2lKS/U7lYGLHQ iat-mode=0"
                "obfs4 37.120.238.182:26565 9C5515135BA35FDB3707CCF3311BC5FF9E2BA3ED cert=ktM7yOCEhCd4Ani9DAo4KGst4BiIp++5yyfCZDbPTz6nty1pn6vuXX14U5nhR+jpZNbSAQ iat-mode=0"
                "obfs4 185.183.34.172:54452 4269C427EED688BBD47E925602A5C557619612AF cert=wUWLiqbQ6K2MnguODPJI5YyMWIBTJqcWJKytY6ZRlc9W5hrn6b/MpePplYkaJUk2cQHgNw iat-mode=0"
                "obfs4 94.156.153.217:31337 AF9EABB157AE185E3D0F030D6F21C2044A794976 cert=Gg+YPaGTlB30p7x45igqEJQ4Af/8HqgbIzwJ1GBzqto1xSDS/k5H83mttmUh0Zob+vrQWw iat-mode=0"
                "obfs4 85.215.50.238:10007 D27430CDF128406ED556434E8F908749EE6D0198 cert=GBiBNfVY/4VSWG6Qx7HmsPMB6WAq80HIr8JUUkTdxsk2L5QdrjdZap8WjyrpaizU58SQGA iat-mode=0"
                "obfs4 31.171.241.111:80 943EC555C2265FAEE461081215224B1ADC7AD919 cert=+jYBlhLKXIWxOaYlDSuwzJ3nwjcWSubWSfmyPrLWGJMi1MACxR1a2otBVqCseTppuzUKbQ iat-mode=0"
                "obfs4 195.201.33.106:59994 91EE0B1CE262E44C7BB96491651F7C86EF65B4D1 cert=AP8yy73Ww8AJYVJ1vnGx6aFJ1F/uRodvbPEpllfXsRHyTyAPV50xQBw+rfKWKdW2qMFVUg iat-mode=0"
                "obfs4 5.75.149.207:29186 1B46786E7FF87921BBB52A0CBBC24B9D40830B63 cert=nss+FABLQKfwYqDVM+WqFz8YCTFzm+pN2xf/9Rk5HMbnnw/Zc/aUk1AJu4uI/2hujYxTeQ iat-mode=0"
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
