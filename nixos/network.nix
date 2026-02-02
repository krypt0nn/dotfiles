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

            # ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";

            # Bridge = builtins.filter (s: s != "") (builtins.map pkgs.lib.strings.trim (pkgs.lib.strings.splitString "\n" ''
            #     obfs4 77.22.111.228:444 31A820940B96F2089E5A235E1B7F09C468A327CA cert=db4/c4C8V0Vl+OJL4vOdVOr73fMfIgLcnG/LWN7ZxQnDeacmu3tSONz9EQD/IM3iSZYwUA iat-mode=0
            #     obfs4 85.215.202.221:2342 F9CD642D3B0D16EF901FAA3974CC3E6628226D10 cert=9NdqO/bPA77Z9pxAC533rWzjyWeADpI6tZO1PZ15m7m/g3kElZji2ZHuq2dxube2HFqFag iat-mode=0
            #     obfs4 185.183.34.172:54452 4269C427EED688BBD47E925602A5C557619612AF cert=wUWLiqbQ6K2MnguODPJI5YyMWIBTJqcWJKytY6ZRlc9W5hrn6b/MpePplYkaJUk2cQHgNw iat-mode=0
            #     obfs4 85.215.50.238:10007 D27430CDF128406ED556434E8F908749EE6D0198 cert=GBiBNfVY/4VSWG6Qx7HmsPMB6WAq80HIr8JUUkTdxsk2L5QdrjdZap8WjyrpaizU58SQGA iat-mode=0
            #     obfs4 82.67.29.26:42024 DE90DE5C6EC2435856CBFE39A0C6E16BC737412E cert=pv4sHJlCcHNiI6gFeAduNdnshJm2J/zPGvJzQ/CvTGfBZAByjzFeYJtpOS1iSIuKRmsdDA iat-mode=0
            #     obfs4 79.117.113.41:52436 54FC151A1C8A58A70CE25AFDF974B9D476E27BBF cert=eKPD8mJfj0KHjlXTBC62SqJZ1JqzSXkY1j9m9PUu8WDNuEFkP2jPiufd3jL4xlA1SD/pQQ iat-mode=0
            #     obfs4 94.104.205.121:7001 B66F75B2391D3C8FC14582621EEDFBD8600B8A0E cert=53Jhn7ty09hmSEzvnUBzW848VpFHTSrpgUfcX/q6MVGVapKBnQ5uDidxz4NBhmxDdoODXQ iat-mode=0
            # ''));

            ClientTransportPlugin = "webtunnel exec ${pkgs.webtunnel}/bin/client";

            Bridge = builtins.filter (s: s != "") (builtins.map pkgs.lib.strings.trim (pkgs.lib.strings.splitString "\n" ''
                webtunnel [2001:db8:77a8:d427:4e0a:8cf7:a2c0:8cda]:443 77B60C7540BA105297FB91DD7BA3557F6ED15C5B url=https://alina-photos.art/da495ccdc73b948387c45c2ab82c1b1aac4b1582 ver=0.0.3
                webtunnel [2001:db8:c151:8ea6:7ecb:78eb:97e9:e26a]:443 F6AC833BA7AE92AD01FA99195EA51BBC3265A6E2 url=https://cdn-133.triplebit.dev/6e7f8g9h0i1j2k3l4m5n6o7p ver=0.0.2
                webtunnel [2001:db8:cb5c:a26a:3b21:2976:2b15:2f74]:443 5115B382BF1F2DC55030B97D59300B3F9B45CAA1 url=https://bors.technology/Ul2qmvTA1F9TikmTFAOWtGoC ver=0.0.2
                webtunnel [2001:db8:3c8c:672:b875:7eac:9c76:ec66]:443 2B936CD554AF5B16678DE517CC3866AA11170BC4 url=https://tech.localenby.is/D0CX0ykTaxzAgALpPd2hBMU6 ver=0.0.3
                webtunnel [2001:db8:8719:f52e:5708:d05:377a:5494]:443 6476A667CC69D29B0AA42A421CA9A0D32698A505 url=https://wtb004.unshakled.net/pl51ucT70jwtW8tjhXL7waaI ver=0.0.3
                webtunnel [2001:db8:603c:2434:873c:4d58:9fd0:91e0]:443 56626E4B996EB1C9F4C0B573888E8EE3C4E28472 url=https://kriptohomyaki.org/4USXwPrEoemgJOXPmgjxPOAkQa1UG7To ver=0.0.3
                webtunnel [2001:db8:ce90:3593:272e:4975:a031:55b]:443 12382A2F3912AD1983A97C8709CBAE47ADB60BE3 url=https://miranda.today/LWwxIXDHCyyScn7oDauPMTmX ver=0.0.3
                webtunnel [2001:db8:ce80:be51:9eda:6869:d906:eec]:443 B5A87A7E786DC0FF2008AC2A3A01E055C5F0D2B0 url=https://cdn-39.triplebit.dev/bohng8PeeDaiy6sh ver=0.0.2
            ''));

            Address = "127.0.0.1";
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
