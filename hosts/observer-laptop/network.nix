{ pkgs, ... }: {
    # Force local DNS usage
    networking.nameservers = pkgs.lib.mkForce [
        "127.0.0.1"
    ];

    # Blocky service for local DNS requests
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
                        "https://raw.githubusercontent.com/cbuijs/oisd/refs/heads/master/big/domains"
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
}
