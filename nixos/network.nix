{ ... }: {
    networking.hosts = {
        # Block telemetry servers
        "0.0.0.0" = [
            # Wuthering Waves
            "pc.crashsight.wetest.net"
        ];
    };

    # Configure networking
    networking = {
        networkmanager = {
            enable = true;
            dns = "none";
        };

        # Use local encrypted DNS resolver
        nameservers = [
            "127.0.0.1"
            "::1"
        ];

        # Cloudflare DNS
        # nameservers = [
        #     "1.1.1.1"
        #     "1.0.0.1"
        # ];
    };

    # Setup encrypted DNS service
    services.dnscrypt-proxy2 = {
        enable = true;

        settings = {
            ipv4_servers = true;
            doh_servers = true;

            require_dnssec = true;
            require_nolog = true;
            require_nofilter = false;

            bootstrap_resolvers = [
                "1.1.1.1:53"
                "1.0.0.1:53"
            ];

            sources = {
                public-resolvers = {
                    urls = [
                        "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
                        "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
                    ];

                    cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
                    minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
                };

                relays = {
                    urls = [
                        "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
                        "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
                    ];

                    cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
                    minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
                };
            };

            server_names = [
                # Ad-blockers DNS
                "adguard-dns-doh"
                "mullvad-base-doh"

                # Normal DNS with content filtering
                "cloudflare-security"
                "switch"
                "adfree.usableprivacy.net"
                "ams-ads-doh-nl"
                "dnsforge.de"
                "doh.tiarap.org"

                # Normal DNS without content filtering
                # "cloudflare"
                # "artikel10-doh-ipv4"
                # "circl-doh"
                # "doh.appliedprivacy.net"
                # "doh.ffmuc.net"
                # "fdn"
                # "meganerd-doh"
            ];

            netprobe_address = "9.9.9.9:53";
        };
    };

    systemd.services.dnscrypt-proxy2.serviceConfig = {
        StateDirectory = "dnscrypt-proxy";
    };
}
