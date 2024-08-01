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
    services.resolved = {
        # Enable DNS queries caching
        enable = true;

        # Do not use any fallback DNS servers
        fallbackDns = [ "" ];
    };

    # Local DNS with queries blocking
    services.blocky = {
        enable = true;

        settings = {
            ports.dns = 53;

            upstreams.groups.default = [
                # Local DNS over Tor
                "127.0.0.1:9053"
            ];

            # These DNS servers are used to resolve upstream DoH and DoT servers
            # that are specified as host names, and list domains
            # 
            # Source: https://0xerr0r.github.io/blocky/latest/configuration/#bootstrap-dns-configuration
            bootstrapDns = {
                upstream = "https://one.one.one.one/dns-query";

                ips = [
                    "1.1.1.1"
                    "1.0.0.1"
                ];
            };

            # Cache DNS queries
            caching = {
                minTime = "5m";
                maxTime = "30m";

                # Preload DNS results for often used queries
                # (default: names queried more than 5 times in a 2 hour time window)
                # 
                # Source: https://0xerr0r.github.io/blocky/latest/configuration/#caching
                prefetching = true;
            };

            blocking = {
                blackLists = {
                    ads = [
                        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
                        "https://blocklistproject.github.io/Lists/ads.txt"
                        "https://blocklistproject.github.io/Lists/tracking.txt"
                    ];

                    illegal = [
                        "https://blocklistproject.github.io/Lists/drugs.txt"
                        "https://blocklistproject.github.io/Lists/fraud.txt"
                        "https://blocklistproject.github.io/Lists/gambling.txt"
                    ];

                    malware = [
                        "https://blocklistproject.github.io/Lists/malware.txt"
                        "https://blocklistproject.github.io/Lists/phishing.txt"
                        "https://blocklistproject.github.io/Lists/ransomware.txt"
                    ];

                    # Meta-blocklists (combination of many others)
                    meta = [
                        # Source: https://github.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist
                        "https://hosts.ubuntu101.co.za/hosts"
                    ];
                };

                clientGroupsBlock = {
                    default = [
                        "ads"
                        "illegal"
                        "malware"
                        "meta"
                    ];
                };
            };
        };
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
                # Aug 1, 2024
                # Avg ping: 34
                "obfs4 82.67.29.26:42024 DE90DE5C6EC2435856CBFE39A0C6E16BC737412E cert=pv4sHJlCcHNiI6gFeAduNdnshJm2J/zPGvJzQ/CvTGfBZAByjzFeYJtpOS1iSIuKRmsdDA iat-mode=0"

                # Aug 1, 2024
                # Avg ping: 36
                "obfs4 95.179.181.148:3479 59A5D54882C6ADEA6E1F9B9ED508479475BFBDCA cert=xX+mvC/OWERv0oZXF6SemAOnXSmujQeP2IhNew3cSskyeZmhqnsaGHBDSw1XEGRkrvH2MA iat-mode=0"

                # Aug 1, 2024
                # Avg ping: 41
                "obfs4 79.137.11.77:56490 A95B850794AC06841FB93F32AD3C997FA8836E52 cert=C+Xz1PxmruAyp9uehauc9u+l+RJG6cZ3x+l3qMJaejVy8iJDTxqi6uOvTxFlrnJL/bMXcg iat-mode=0"

                # Aug 1, 2024
                # Avg ping: 43
                "obfs4 162.19.69.238:59668 F4D08575F002C698B690ADA9E3D4AD7E7523CB46 cert=aQKxA5NJEudoj8JLRy8pONs3GBhZbRYMAd2sjzev2dS6roWhQcu/CCVwBFynOtZC1Uu4OQ iat-mode=0"

                # Aug 1, 2024
                # Avg ping: 46
                "obfs4 51.91.211.22:30314 EB58799CC45EE3430DF20112D7BAED05BBD4CCD4 cert=3kGMw/fAF+Lk8z1mpuNtULveQITOp4yMDnDTIXwmK4jiN6pqDrK3239nzGXSM1XLctT2cA iat-mode=0"
            ];

            DNSPort = [
                {
                    addr = "127.0.0.1";
                    port = 9053;
                }
            ];

            CookieAuthentication = true;
            HardwareAccel = 1;
        };
    };
}
