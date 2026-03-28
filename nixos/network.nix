{ pkgs, ... }: {
    networking = {
        firewall = {
            enable = true;

            allowedTCPPorts = [
                # Tor
                9050

                # BitTorrent
                9090
            ];

            allowedUDPPorts = [
                # BitTorrent
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
                webtunnel [2001:db8:cb5c:a26a:3b21:2976:2b15:2f74]:443 5115B382BF1F2DC55030B97D59300B3F9B45CAA1 url=https://bors.technology/Ul2qmvTA1F9TikmTFAOWtGoC ver=0.0.2
                webtunnel [2001:db8:3c8c:672:b875:7eac:9c76:ec66]:443 2B936CD554AF5B16678DE517CC3866AA11170BC4 url=https://tech.localenby.is/D0CX0ykTaxzAgALpPd2hBMU6 ver=0.0.3
                webtunnel [2001:db8:ce90:3593:272e:4975:a031:55b]:443 12382A2F3912AD1983A97C8709CBAE47ADB60BE3 url=https://miranda.today/LWwxIXDHCyyScn7oDauPMTmX ver=0.0.3
                webtunnel [2001:db8:9de4:c800:cc50:4c26:b192:b006]:443 1F5CA44230E96911836158A474E2AEB16EAEA57C url=https://ghosttown.dev/MTwam63OSHyUPQPcRRw8hx50 ver=0.0.2
                webtunnel [2001:db8:dee9:5852:b4dc:7e14:21bd:c99b]:443 8ADF1761FA735FDD763781BB94A16EAB64A1CF6C url=https://app01.oneclickhost.eu/WJSgXJRlNnMStkuLZygVJ7lo ver=0.0.3
                webtunnel [2001:db8:a12b:ff8:8a1a:a05b:5f21:2ccc]:443 F2A9C5AEE0A420EB9D55F9497B3C0FA243A2A770 url=https://bridge.lovecloud.me/wss-wc3p0euqrlne98t9 ver=0.0.3
                webtunnel [2001:db8:1da7:e44a:892b:6ada:b3e2:4160]:443 ACBB486B9D60979A05E623D11CC8181A16A81E51 url=https://usa.bulger.au/7gBqm1jbTOpU0jLV91IZHN0f ver=0.0.1
                webtunnel [2001:db8:eedb:cae7:a345:4f72:f9cc:5de0]:443 B3C81E7A0CA474270DAA4A2C8633E1CA8935C37D url=https://wordpress.far-east-investment.ru/sORes7268CEUSRD7hAWvJU5A ver=0.0.3
                webtunnel [2001:db8:c151:8ea6:7ecb:78eb:97e9:e26a]:443 F6AC833BA7AE92AD01FA99195EA51BBC3265A6E2 url=https://cdn-133.triplebit.dev/6e7f8g9h0i1j2k3l4m5n6o7p ver=0.0.2
                webtunnel [2001:db8:c28f:ab8d:dcc9:fdc2:7a6f:bef8]:443 B61E2E1E85B147F0FEAFBFB6FF6B5E5879ADA8B2 url=https://bbb.bm-dataprotect.ch/Csnoegi9ll226X5DLDzKDDjc ver=0.0.3
                webtunnel [2001:db8:d513:341f:d853:76fe:aaf1:dedc]:443 C94F0B257D1950B17BB2147021B0E07C5891007A url=https://r4fo.com/7z0hLnrTxvkPIHmuPH94Ju2J ver=0.0.3
                webtunnel [2001:db8:43cc:d277:5ba1:dcd1:516e:d983]:443 AD62C15FAC9C8695F41F4BB5D1F16373F906177F url=https://mitch.pmvl.eu/r9mZqSFwOHSQATtQoPWwZQk9 ver=0.0.1
                webtunnel [2001:db8:8ed6:e6c9:5fc9:9f20:a373:2374]:443 1636A2EFFBAA4B162F5FF461A1663EB55C41AE11 url=https://hanoi.delivery/roQFPLtlspWT6yIKeXD6lEci ver=0.0.3
                webtunnel [2001:db8:3be7:5113:eddb:210d:291f:b52c]:443 B6CFDBD17618C147903429AB1C0CC759933DB50E url=https://adm.unicoridor.ru/rtASSYlOJgl1nKtH8njdZLbs ver=0.0.3
                webtunnel [2001:db8:915d:6373:6498:cec4:859d:4409]:443 0141998B7435FDFCE175410D5309C8EF2379EA68 url=https://homu.io/1zRuET5Xz19MUA4IwqbgUrcP ver=0.0.2
                webtunnel [2001:db8:75a1:8038:7326:46ce:b078:370b]:443 2C9FF2DE2E07A722BCF233E607947241887FF295 url=https://app03.oneclickhost.eu/rTl1ijNSNKZzskFsMjNMRI0p ver=0.0.4
                webtunnel [2001:db8:1b1d:debc:1c57:32bf:5baf:5948]:443 62B3904A4F84BF916310286FFEFE4CB4D24BFAFE url=https://dashboard-132.3b.lol/5d6e7f8g9h0i1j2k3l4m5n6o ver=0.0.2
                webtunnel [2001:db8:f197:d667:1bc:b8f8:11f8:3db3]:443 1EED406D8DDEEF14AFB3BDA02EA4C0596CCB756F url=https://privacee.top/JCRnZyuyEjXmihH8rbeVcyxH ver=0.0.3
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

    # Persist folders
    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            { directory = "/var/lib/tailscale"; mode = "0700"; }
            { directory = "/var/lib/tor"; mode = "0700"; }
        ];
    };
}
