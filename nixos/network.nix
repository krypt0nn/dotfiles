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
                # 25565

                # Factorio
                # 34197
                # 53747
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
                "obfs4 37.120.238.182:26565 9C5515135BA35FDB3707CCF3311BC5FF9E2BA3ED cert=ktM7yOCEhCd4Ani9DAo4KGst4BiIp++5yyfCZDbPTz6nty1pn6vuXX14U5nhR+jpZNbSAQ iat-mode=0"
                "obfs4 185.183.34.172:54452 4269C427EED688BBD47E925602A5C557619612AF cert=wUWLiqbQ6K2MnguODPJI5YyMWIBTJqcWJKytY6ZRlc9W5hrn6b/MpePplYkaJUk2cQHgNw iat-mode=0"
                "obfs4 85.215.50.238:10007 D27430CDF128406ED556434E8F908749EE6D0198 cert=GBiBNfVY/4VSWG6Qx7HmsPMB6WAq80HIr8JUUkTdxsk2L5QdrjdZap8WjyrpaizU58SQGA iat-mode=0"
                "obfs4 195.201.33.106:59994 91EE0B1CE262E44C7BB96491651F7C86EF65B4D1 cert=AP8yy73Ww8AJYVJ1vnGx6aFJ1F/uRodvbPEpllfXsRHyTyAPV50xQBw+rfKWKdW2qMFVUg iat-mode=0"
                "obfs4 5.75.149.207:29186 1B46786E7FF87921BBB52A0CBBC24B9D40830B63 cert=nss+FABLQKfwYqDVM+WqFz8YCTFzm+pN2xf/9Rk5HMbnnw/Zc/aUk1AJu4uI/2hujYxTeQ iat-mode=0"
                "obfs4 198.50.223.26:80 A75FC19718138D8CD35AE2820E840D8E2BAC595F cert=l8/Zh4z+5/DBh8HBOyC4+nG6ygBFsJ+FWB3Ib+0U335kWFzoWpWTlra8tj9JS15s3uJ/Zg iat-mode=1"
                "obfs4 57.128.56.248:30285 1CF4ED5D3C7F4E3BFB485DDA5C7E688BEBBAE9DA cert=wC6H6x0IDrTeIKVqOzzDAfZQxU6eyB2Eg/auzam+XCMWzQLHl3+qfgbqhMQxV7K3uQRMZw iat-mode=0"
                "obfs4 51.68.81.140:2098 F205CB5B969389061477609F8E03470B982F64C1 cert=6hFyrclX8Cg16jHGbtYqZxbGxj+p0flBn2EYZu+hvx/tGL4GROXSvBtwVQ1sRYFbi0++fQ iat-mode=0"
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
