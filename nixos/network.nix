{ pkgs, ... }: {
    networking = {
        firewall = {
            enable = true;

            allowedTCPPorts = [
                # Tor
                9050

                # Torrent client
                9090
            ];

            allowedUDPPorts = [
                # Torrent client
                9090
            ];
        };

        networkmanager = {
            enable = true;
            dns = "none";
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

    # Tor
    services.tor = {
        enable = true;

        client = {
            enable = true;

            socksListenAddress = {
                addr = "0.0.0.0";
                port = 9050;
                flags = [
                    "IsolateClientAddr"
                    "IsolateDestAddr"
                ];
            };
        };

        settings = {
            UseBridges = true;

            ClientTransportPlugin = "webtunnel exec ${pkgs.webtunnel}/bin/client";

            Bridge = builtins.filter (s: s != "") (builtins.map pkgs.lib.strings.trim (pkgs.lib.strings.splitString "\n" ''
                webtunnel [2001:db8:77a8:d427:4e0a:8cf7:a2c0:8cda]:443 77B60C7540BA105297FB91DD7BA3557F6ED15C5B url=https://alina-photos.art/da495ccdc73b948387c45c2ab82c1b1aac4b1582 ver=0.0.3
                webtunnel [2001:db8:c151:8ea6:7ecb:78eb:97e9:e26a]:443 F6AC833BA7AE92AD01FA99195EA51BBC3265A6E2 url=https://cdn-133.triplebit.dev/6e7f8g9h0i1j2k3l4m5n6o7p ver=0.0.2
                webtunnel [2001:db8:cb5c:a26a:3b21:2976:2b15:2f74]:443 5115B382BF1F2DC55030B97D59300B3F9B45CAA1 url=https://bors.technology/Ul2qmvTA1F9TikmTFAOWtGoC ver=0.0.2
                webtunnel [2001:db8:3c8c:672:b875:7eac:9c76:ec66]:443 2B936CD554AF5B16678DE517CC3866AA11170BC4 url=https://tech.localenby.is/D0CX0ykTaxzAgALpPd2hBMU6 ver=0.0.3
                webtunnel [2001:db8:603c:2434:873c:4d58:9fd0:91e0]:443 56626E4B996EB1C9F4C0B573888E8EE3C4E28472 url=https://kriptohomyaki.org/4USXwPrEoemgJOXPmgjxPOAkQa1UG7To ver=0.0.3
                webtunnel [2001:db8:ce90:3593:272e:4975:a031:55b]:443 12382A2F3912AD1983A97C8709CBAE47ADB60BE3 url=https://miranda.today/LWwxIXDHCyyScn7oDauPMTmX ver=0.0.3
                webtunnel [2001:db8:e65a:afaf:7443:b5a5:f71d:ca4]:443 6FE31638D6084EDA6D94FADC99B0EDD109D6AE3A url=https://eu.g3wip.uk/7ePavP0vnTTelEJWeJ4NwpGE ver=0.0.1
                webtunnel [2001:db8:87a6:51bd:ecd9:3d12:e0e3:1baa]:443 3683B1036F18DF4B560865C17AF85C373232A8D5 url=https://q.igrp.site/pg9PbqaxSvIbjtbVZMt9H7xF ver=0.0.3
                webtunnel [2001:db8:9de4:c800:cc50:4c26:b192:b006]:443 1F5CA44230E96911836158A474E2AEB16EAEA57C url=https://ghosttown.dev/MTwam63OSHyUPQPcRRw8hx50 ver=0.0.2
                webtunnel [2001:db8:44:614b:42f5:f87c:7072:151]:443 F0C55D7B465C94F71A9A8F0479073BC02565DA36 url=https://quantentoast.de/CDgakmo0QO5Rvo2jRCtu4n9D ver=0.0.1
                webtunnel [2001:db8:8229:577b:8f3a:bc4c:7d18:24be]:443 4C26D2BA24011E89875857BDB338969D08CAAE0B url=https://test.notalot.org/ApKhNDWZv4MCjbH05W6eQFkF ver=0.0.2
                webtunnel [2001:db8:dee9:5852:b4dc:7e14:21bd:c99b]:443 8ADF1761FA735FDD763781BB94A16EAB64A1CF6C url=https://app01.oneclickhost.eu/WJSgXJRlNnMStkuLZygVJ7lo ver=0.0.3
                webtunnel [2001:db8:12ff:2d55:9130:36a7:c49b:d1f4]:443 933C998EC827D1C17CC93D1292BBC41735867CF8 url=https://x7t2qctb.xoomlia.com/qzxrtfmu/ ver=0.0.3
                webtunnel [2001:db8:ce80:be51:9eda:6869:d906:eec]:443 B5A87A7E786DC0FF2008AC2A3A01E055C5F0D2B0 url=https://cdn-39.triplebit.dev/bohng8PeeDaiy6sh ver=0.0.2
            ''));

            HardwareAccel = true;

            ClientOnly = true;
            ClientUseIPv6 = true;

            ExitRelay = false;
            BridgeRelay = false;

            ExitNodes = [
                "{de}" # Germany
                "{dk}" # Denmark
                "{at}" # Austria
                "{be}" # Belgium
                "{nl}" # Netherlands
                "{pl}" # Poland
                "{cz}" # Czech Republic
                "{hu}" # Hungary
                "{fi}" # Findland
                "{se}" # Sweden
                "{ee}" # Estonia
                "{lt}" # Lithuania
                "{lv}" # Latvia
            ];

            StrictNodes = true;
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
