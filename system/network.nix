{ hostname, pkgs, lib, ... }: {
    networking = {
        firewall = {
            enable = true;

            allowedTCPPorts = [
                # Tor
                9050

                # BitTorrent
                9090 9091

                # Minecraft
                25565
            ];

            allowedUDPPorts = [
                # BitTorrent
                9090 9091

                # Minecraft
                25565
            ];
        };

        networkmanager.enable = true;

        nameservers = [
            "192.168.1.1"
        ];

        # Search domain for short tailnet names, e.g. "observer-server".
        # Only completes names in this domain; see services.resolved below.
        search = [
            "emperor-interval.ts.net"
        ];
    };

    # Split DNS for Tailscale.
    #
    # Without systemd-resolved, Tailscale falls back to its resolvconf manager
    # and rewrites /etc/resolv.conf wholesale, which is what it does today:
    #   search emperor-interval.ts.net
    #   nameserver 100.100.100.100
    #   nameserver fd7a:115c:a1e8::53
    # Every lookup, github.com included, then goes through MagicDNS.
    #
    # With resolved running, Tailscale uses its D-Bus manager instead and only
    # adds a routing-only domain (~emperor-interval.ts.net) pointing at
    # 100.100.100.100. Tailnet names resolve via MagicDNS, everything else goes
    # straight to the nameservers above, which is the default for
    # services.resolved.settings.DNS.
    services.resolved.enable = true;

    # .local domains resolver
    services.avahi = {
        enable = true;
        nssmdns4 = true;
    };

    # Tailscale
    services.tailscale = {
        enable = true;

        # We don't need tailscale to access local network hosts on PC.
        extraSetFlags = lib.optionals (hostname == "observer-pc") [
            "--accept-routes=false"
        ];
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

            Bridge = builtins.filter (s: s != "") (map pkgs.lib.strings.trim (pkgs.lib.strings.splitString "\n" ''
                webtunnel [2001:db8:cb5c:a26a:3b21:2976:2b15:2f74]:443 5115B382BF1F2DC55030B97D59300B3F9B45CAA1 url=https://bors.technology/Ul2qmvTA1F9TikmTFAOWtGoC ver=0.0.2
                webtunnel [2001:db8:3c8c:672:b875:7eac:9c76:ec66]:443 2B936CD554AF5B16678DE517CC3866AA11170BC4 url=https://tech.localenby.is/D0CX0ykTaxzAgALpPd2hBMU6 ver=0.0.3
                webtunnel [2001:db8:dee9:5852:b4dc:7e14:21bd:c99b]:443 8ADF1761FA735FDD763781BB94A16EAB64A1CF6C url=https://app01.oneclickhost.eu/WJSgXJRlNnMStkuLZygVJ7lo ver=0.0.3
                webtunnel [2001:db8:a12b:ff8:8a1a:a05b:5f21:2ccc]:443 F2A9C5AEE0A420EB9D55F9497B3C0FA243A2A770 url=https://bridge.lovecloud.me/wss-wc3p0euqrlne98t9 ver=0.0.3
                webtunnel [2001:db8:1da7:e44a:892b:6ada:b3e2:4160]:443 ACBB486B9D60979A05E623D11CC8181A16A81E51 url=https://usa.bulger.au/7gBqm1jbTOpU0jLV91IZHN0f ver=0.0.1
                webtunnel [2001:db8:c151:8ea6:7ecb:78eb:97e9:e26a]:443 F6AC833BA7AE92AD01FA99195EA51BBC3265A6E2 url=https://cdn-133.triplebit.dev/6e7f8g9h0i1j2k3l4m5n6o7p ver=0.0.2
                webtunnel [2001:db8:d513:341f:d853:76fe:aaf1:dedc]:443 C94F0B257D1950B17BB2147021B0E07C5891007A url=https://r4fo.com/7z0hLnrTxvkPIHmuPH94Ju2J ver=0.0.3
                webtunnel [2001:db8:3be7:5113:eddb:210d:291f:b52c]:443 B6CFDBD17618C147903429AB1C0CC759933DB50E url=https://adm.unicoridor.ru/rtASSYlOJgl1nKtH8njdZLbs ver=0.0.3
                webtunnel [2001:db8:75a1:8038:7326:46ce:b078:370b]:443 2C9FF2DE2E07A722BCF233E607947241887FF295 url=https://app03.oneclickhost.eu/rTl1ijNSNKZzskFsMjNMRI0p ver=0.0.4
                webtunnel [2001:db8:1b1d:debc:1c57:32bf:5baf:5948]:443 62B3904A4F84BF916310286FFEFE4CB4D24BFAFE url=https://dashboard-132.3b.lol/5d6e7f8g9h0i1j2k3l4m5n6o ver=0.0.2
                webtunnel [2001:db8:adeb:7e0f:5140:7cd5:28b1:4503]:443 32F772D0970C2849B2B5BF9F0EC9D3F878DAEA43 url=https://files.bitrot.cz/Bho2k74VTFX6Bwr2XJG5V8gLhZEKgRQ5 ver=0.0.4
                webtunnel [2001:db8:1c6b:27b9:a0a4:aa4:fa98:2734]:443 CE95A839CADA1ED38508B099C6C610CBB0EA7F81 url=https://cdn-37.triplebit.dev/oxaiBaa6ierohquu ver=0.0.2
                webtunnel [2001:db8:1640:379c:ad30:db5f:bff5:37d0]:443 AF8F7548C886D6F53A652411DBB71D089517085A url=https://app05.oneclickhost.eu/alpfZGTB9FckCgOkOOA0OHlh ver=0.0.3
                webtunnel [2001:db8:ecc6:9ade:63b6:e98f:fac6:dc89]:443 C2C9072B0FAA99F95AE6A6899203AB0978B7CC4A url=https://www2.shouldiblockads.com/aTzB6XNVkeh2XqT9XQ0RHmHw ver=0.0.2
                webtunnel [2001:db8:72cd:a490:2485:20b0:4987:35ec]:443 C0B90984E829C31BB316CCB8A89CB4F318891871 url=https://download-134.as401332.net/7f8g9h0i1j2k3l4m5n6o7p8q ver=0.0.2
                webtunnel [2001:db8:b1d5:4998:8150:f75b:988f:1f48]:443 216C8BB1C44FC2BFF7AF823B55AC38F113079B93 url=https://cdn-38.triplebit.dev/Bai8aXeiPhar5gai ver=0.0.2
                webtunnel [2001:db8:cf6:ce7:c7fc:5a42:72d5:8c8b]:443 D0A1F802127A925F47A7C9713F17A9E1D1292E54 url=https://cdn-131.airstrip1.net/4c5d6e7f8g9h0i1j2k3l4m5n ver=0.0.2
                webtunnel [2001:db8:50a9:c546:36be:96ad:4cd1:cfff]:443 D20CE64A82CF6E6DB6F4F95C1F8FA81B06C10888 url=https://cdn-35.triplebit.dev/iethae6ahvoo1ieV ver=0.0.2
                webtunnel [2001:db8:8823:18d4:77e:e206:ef9c:627f]:443 241136D5BB0CA8120EF269AF7CB8A427CA23ED55 url=https://ardc.bulger.co.uk/bxSqZSmsNykSCHI1gp6zl94a ver=0.0.4
                webtunnel [2001:db8:fe46:edd5:2139:2d5b:b732:854a]:443 6C0D57943B9AE19F4365FE98E068126003DA6D29 url=https://bridge.skyhong.tw/ee282d33589b789bf7e31653bcbaa9c195d7 ver=0.0.4
                webtunnel [2001:db8:1f1e:4d2f:321b:6626:823e:c504]:443 4946C9B8410CF59953455C158F957CAB2055A61D url=https://mstdn.party/fooghee7naChifi0 ver=0.0.2
                webtunnel [2001:db8:2091:9afb:4e45:7aab:e2d0:a8c7]:443 3683B1036F18DF4B560865C17AF85C373232A8D5 url=https://o.ofdma.de/pg9PbqaxSvIbjtbVZMt9H7xF ver=0.0.5
                webtunnel [2001:db8:e026:e32:d3ef:1ddf:4a96:4386]:443 25E15F4A7E69AAF062B8353C4C37DD35D5417837 url=https://app04.oneclickhost.eu/dLHKfx5cEep0SWfJCLQqIBGF ver=0.0.6
                webtunnel [2001:db8:9513:a2a7:e8de:e859:2818:6694]:443 34E2AC0B23D523B789EAD6E193DC05078943B94D url=https://us04-buf.beijing.st/fromwhereyoupickupthisgarbage ver=0.0.4
                webtunnel [2001:db8:d0f2:6cd4:8630:8185:18d2:a5c]:443 5A94C0CDB0ED58681BDAA8FDBC53F5C9E32058F8 url=https://beefstrognoff.com/xRiEjTMRdkc9l7vrlASBmOus ver=0.0.4
                webtunnel [2001:db8:c28f:ab8d:dcc9:fdc2:7a6f:bef8]:443 B61E2E1E85B147F0FEAFBFB6FF6B5E5879ADA8B2 url=https://bbb.bm-dataprotect.ch/Csnoegi9ll226X5DLDzKDDjc ver=0.0.3
                webtunnel [2001:db8:eedb:cae7:a345:4f72:f9cc:5de0]:443 B3C81E7A0CA474270DAA4A2C8633E1CA8935C37D url=https://wordpress.far-east-investment.ru/sORes7268CEUSRD7hAWvJU5A ver=0.0.6
                webtunnel [2001:db8:ea81:4de2:7f00:a080:8837:d7eb]:443 9FE1D3DE54B27FF2EB97A8E17FD0D352FFBA0310 url=https://viewletwhogdd.com/7TulQJ69bUWvTefBJRhSz7gE ver=0.0.5
                webtunnel [2001:db8:12b1:a936:2095:ea48:63c4:2ffb]:443 5E5A525225F61595EB860044FB3E630C1A77DAEE url=https://secretinsociety.com/FuL5N2y4Tan9Wv4Xbsl2T4Ld ver=0.0.4
                webtunnel [2001:db8:39ff:b176:96c8:fe95:7795:6a84]:443 8A619BB4906C5BA1CE1C411B39C5191991741BBF url=https://benches.date/Zjx8DRPQrFZUpUTdpFNu7x3r ver=0.0.7
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
            "/var/lib/tailscale"
            "/var/cache/tailscale"
            "/var/lib/tor"
        ];
    };
}
