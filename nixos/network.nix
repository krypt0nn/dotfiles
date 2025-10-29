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
                "obfs4 77.22.111.228:444 31A820940B96F2089E5A235E1B7F09C468A327CA cert=db4/c4C8V0Vl+OJL4vOdVOr73fMfIgLcnG/LWN7ZxQnDeacmu3tSONz9EQD/IM3iSZYwUA iat-mode=0"
                "obfs4 85.215.202.221:2342 F9CD642D3B0D16EF901FAA3974CC3E6628226D10 cert=9NdqO/bPA77Z9pxAC533rWzjyWeADpI6tZO1PZ15m7m/g3kElZji2ZHuq2dxube2HFqFag iat-mode=0"
                "obfs4 46.226.107.235:57180 93BD2E597D164D9FE9C74BF3E0F68531AC17EFB2 cert=lkV0hpUCIEEpU1nIFGnBJoabeXn0BFykm3NIf4an09Kq8nTK+qv6Z3A1i3Rkkc3hGMoqSA iat-mode=0"
                "obfs4 185.183.34.172:54452 4269C427EED688BBD47E925602A5C557619612AF cert=wUWLiqbQ6K2MnguODPJI5YyMWIBTJqcWJKytY6ZRlc9W5hrn6b/MpePplYkaJUk2cQHgNw iat-mode=0"
                "obfs4 85.215.50.238:10007 D27430CDF128406ED556434E8F908749EE6D0198 cert=GBiBNfVY/4VSWG6Qx7HmsPMB6WAq80HIr8JUUkTdxsk2L5QdrjdZap8WjyrpaizU58SQGA iat-mode=0"
                "obfs4 162.55.219.253:21358 A43C6D5A85CE5D52486293C507983409ED7C1EC0 cert=t0TUwf8Gu+jz8nxWYAPR/VMqh9k8+efrZFTIg6HNpitEdNH1fT1KlAz51jAZqxQq8/9nEA iat-mode=0"
                "obfs4 82.67.29.26:42024 DE90DE5C6EC2435856CBFE39A0C6E16BC737412E cert=pv4sHJlCcHNiI6gFeAduNdnshJm2J/zPGvJzQ/CvTGfBZAByjzFeYJtpOS1iSIuKRmsdDA iat-mode=0"
                "obfs4 95.217.11.29:22134 9859875C752128125D3179F90BA6351744B09040 cert=W+qSHr6JcFY6UyJiXR3Ec5I5bYHFwDAXNq8HRQU3C56h/aJB8PQqbr8Sq04zKvhEWGbxEw iat-mode=0"
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
