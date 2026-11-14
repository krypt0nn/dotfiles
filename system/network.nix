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

        # PC and server listen to fake-ip DNS running on router, while laptop
        # is using throne with its own local DNS server.
        networkmanager = {
            enable = true;

            # resolved.nix sets this to "systemd-resolved" for every host as
            # soon as services.resolved is on (mkIf cfg.enable, plain
            # definition at priority 100), so anything else has to be forced.
            dns = {
                "observer-pc" = lib.mkDefault "default";
                "observer-laptop" = lib.mkForce "none";
                "observer-server" = lib.mkDefault "default";
            }.${hostname};
        };

        nameservers = {
            "observer-pc" = [ "192.168.1.1" ];
            "observer-laptop" = [ "127.0.0.1" ];
            "observer-server" = [ "192.168.1.1" ];
        }.${hostname};

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
                webtunnel [2001:db8:a12b:ff8:8a1a:a05b:5f21:2ccc]:443 F2A9C5AEE0A420EB9D55F9497B3C0FA243A2A770 url=https://bridge.lovecloud.me/wss-wc3p0euqrlne98t9 ver=0.0.3
                webtunnel [2001:db8:1da7:e44a:892b:6ada:b3e2:4160]:443 ACBB486B9D60979A05E623D11CC8181A16A81E51 url=https://usa.bulger.au/7gBqm1jbTOpU0jLV91IZHN0f ver=0.0.1
                webtunnel [2001:db8:c151:8ea6:7ecb:78eb:97e9:e26a]:443 F6AC833BA7AE92AD01FA99195EA51BBC3265A6E2 url=https://cdn-133.triplebit.dev/6e7f8g9h0i1j2k3l4m5n6o7p ver=0.0.2
                webtunnel [2001:db8:1b1d:debc:1c57:32bf:5baf:5948]:443 62B3904A4F84BF916310286FFEFE4CB4D24BFAFE url=https://dashboard-132.3b.lol/5d6e7f8g9h0i1j2k3l4m5n6o ver=0.0.2
                webtunnel [2001:db8:adeb:7e0f:5140:7cd5:28b1:4503]:443 32F772D0970C2849B2B5BF9F0EC9D3F878DAEA43 url=https://files.bitrot.cz/Bho2k74VTFX6Bwr2XJG5V8gLhZEKgRQ5 ver=0.0.4
                webtunnel [2001:db8:1c6b:27b9:a0a4:aa4:fa98:2734]:443 CE95A839CADA1ED38508B099C6C610CBB0EA7F81 url=https://cdn-37.triplebit.dev/oxaiBaa6ierohquu ver=0.0.2
                webtunnel [2001:db8:1640:379c:ad30:db5f:bff5:37d0]:443 AF8F7548C886D6F53A652411DBB71D089517085A url=https://app05.oneclickhost.eu/alpfZGTB9FckCgOkOOA0OHlh ver=0.0.3
                webtunnel [2001:db8:ecc6:9ade:63b6:e98f:fac6:dc89]:443 C2C9072B0FAA99F95AE6A6899203AB0978B7CC4A url=https://www2.shouldiblockads.com/aTzB6XNVkeh2XqT9XQ0RHmHw ver=0.0.2
                webtunnel [2001:db8:72cd:a490:2485:20b0:4987:35ec]:443 C0B90984E829C31BB316CCB8A89CB4F318891871 url=https://download-134.as401332.net/7f8g9h0i1j2k3l4m5n6o7p8q ver=0.0.2
                webtunnel [2001:db8:b1d5:4998:8150:f75b:988f:1f48]:443 216C8BB1C44FC2BFF7AF823B55AC38F113079B93 url=https://cdn-38.triplebit.dev/Bai8aXeiPhar5gai ver=0.0.2
                webtunnel [2001:db8:cf6:ce7:c7fc:5a42:72d5:8c8b]:443 D0A1F802127A925F47A7C9713F17A9E1D1292E54 url=https://cdn-131.airstrip1.net/4c5d6e7f8g9h0i1j2k3l4m5n ver=0.0.2
                webtunnel [2001:db8:50a9:c546:36be:96ad:4cd1:cfff]:443 D20CE64A82CF6E6DB6F4F95C1F8FA81B06C10888 url=https://cdn-35.triplebit.dev/iethae6ahvoo1ieV ver=0.0.2
                webtunnel [2001:db8:1f1e:4d2f:321b:6626:823e:c504]:443 4946C9B8410CF59953455C158F957CAB2055A61D url=https://mstdn.party/fooghee7naChifi0 ver=0.0.2
                webtunnel [2001:db8:2091:9afb:4e45:7aab:e2d0:a8c7]:443 3683B1036F18DF4B560865C17AF85C373232A8D5 url=https://o.ofdma.de/pg9PbqaxSvIbjtbVZMt9H7xF ver=0.0.5
                webtunnel [2001:db8:75a1:8038:7326:46ce:b078:370b]:443 2C9FF2DE2E07A722BCF233E607947241887FF295 url=https://app03.oneclickhost.eu/rTl1ijNSNKZzskFsMjNMRI0p ver=0.0.7
                webtunnel [2001:db8:4a7:f9d5:dd5:a50d:e609:b356]:443 0FF5783D11A1B411A5815CE0C6C25AD584D281FE url=https://cdn.xoomlia.com/dzq3/ ver=0.0.3
                webtunnel [2001:db8:c726:7e6a:522:7dc3:bd07:e21f]:443 F9928874DE5B119F9F80ABDF8124DCC1C2AEE57B url=https://dev.jonahtreiber.com/5tJkLPQvuGwWyrU6eFsSFFJx ver=0.0.7
                webtunnel [2001:db8:3532:d0b6:b59e:acfb:f6ed:a40e]:443 81DCDD5A242A10CA419E7CE477DBE3BD00A9DAB0 url=https://wedo.cyou/4fdDGGRIMtLFi2bmq4rxLbti ver=0.0.4
            ''));

            HardwareAccel = true;

            ClientOnly = true;
            ClientUseIPv6 = true;

            ExitRelay = false;
            BridgeRelay = false;

            ExitNodes = [
                "{de}" # Germany
                "{pl}" # Poland
                "{fi}" # Findland
                "{se}" # Sweden
                "{lt}" # Lithuania
                "{lv}" # Latvia
                "{ee}" # Estonia
                "{nl}" # Netherlands
                "{be}" # Belgium
                "{dk}" # Denmark
                "{at}" # Austria
                "{hu}" # Hungary
                "{cz}" # Czech Republic
                "{it}" # Italy
                "{fr}" # France
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
