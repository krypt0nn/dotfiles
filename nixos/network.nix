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
            dns = "none";
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

    # Tailscale
    services.tailscale.enable = true;

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
                };

                clientGroupsBlock.default = [
                    "ads"
                ];
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
                "obfs4 83.226.191.248:2048 6FEC97F7437D5451211B42F35784FC2A436C2610 cert=3ubRj29BI4QtyMOVI/XiIE8tNTIypFqj5FtAtSnqMSdNu2ot43UL8PJ4U2c+asMV8YjZeA iat-mode=0"
                "obfs4 150.43.248.236:443 E69FD1828D270D6F7DD94B1B2C5261CBF1A32583 cert=o3UL0xikRiafXXdnzXC3puRCDEaN7cRhwu+/0VnTcyVIgxFmg/Ds+LEGx2lKS/U7lYGLHQ iat-mode=0"
                "obfs4 37.120.238.182:26565 9C5515135BA35FDB3707CCF3311BC5FF9E2BA3ED cert=ktM7yOCEhCd4Ani9DAo4KGst4BiIp++5yyfCZDbPTz6nty1pn6vuXX14U5nhR+jpZNbSAQ iat-mode=0"
                "obfs4 185.183.34.172:54452 4269C427EED688BBD47E925602A5C557619612AF cert=wUWLiqbQ6K2MnguODPJI5YyMWIBTJqcWJKytY6ZRlc9W5hrn6b/MpePplYkaJUk2cQHgNw iat-mode=0"
                "obfs4 141.94.213.29:34975 3CCF6211A6115BA32224E939C179AC2F8269E186 cert=xFW3DRM458PUIuWgi74qRg8IG7JElyFJIYgy9+V+flBQuvfKKonuPJb373QooLLR+eIqMg iat-mode=0"
                "obfs4 57.128.35.251:17275 3411026D454DF9F94BB263BCED2CFBECEBBAAF4C cert=nDA6sKSsjz28b1XZVZwZcx2dBbRSdYFZR5yvenhtFKQA7zYY6N2otTaa562gZViSNSW9Kg iat-mode=0"
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
