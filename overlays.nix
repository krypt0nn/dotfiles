{
    # Overlay any package to use a proxy.
    # Example: proxy { pkg = "curl"; }
    proxy = {
        pkg,
        mode ? "https",
        proxy ? "socks5://127.0.0.1:9050",
        dns ? "127.0.0.1",
        ignore ? "127.0.0.1,::1,localhost,.localdomain.com",
        bypass ? [
            "127.0.0.0/24"
            "192.168.0.0/24"
            "10.0.0.0/24"
            "100.64.0.0/10" # Tailscale: https://tailscale.com/kb/1015/100.x-addresses
        ]
    }: self: super: {
        ${pkg} = let
            bypassFlags = builtins.concatStringsSep " " (
                map (cidr: "--bypass '${cidr}'") bypass
            );
        in super.symlinkJoin {
            name = pkg;
            paths = [ super.${pkg} ];
            buildInputs = [ super.makeWrapper ];
            postBuild = ''
                wrapProgram $out/bin/${pkg} \
                    --set ${super.lib.strings.toLower mode}_proxy ${proxy} \
                    --set ${super.lib.strings.toUpper mode}_PROXY ${proxy} \
                    --set no_proxy "${ignore}" \
                    --run "${super.tun2proxy}/bin/tun2proxy-bin --setup --unshare --ipv6-enabled --proxy '${proxy}' --dns-addr '${dns}' --bypass '${dns}' ${bypassFlags} --verbosity off --exit-on-fatal-error -- bash -c 'PID1=\$(ps -eo pid,ppid | grep \"\$\$ \" | awk \"{print \\\$2}\"); PID2=\$(ps -eo pid,ppid | grep \"\$PID1 \" | awk \"{print \\\$2}\"); echo -n \$PID2 > \"${pkg}.pid\"' &" \
                    --run "sleep 1" \
                    --run "DAEMON_PID=\$(cat '${pkg}.pid')" \
                    --run "rm '${pkg}.pid'" \
                    --run "nsenter --preserve-credentials --user --net --target \"\$DAEMON_PID\" bash -c '" \
                    --append-flags "'
                        kill \"\$DAEMON_PID\""
            '';
        };
    };

    # Pin specified package to the version under provided nixpkgs revision.
    # Example: pin { pkg = "mission-center"; rev = "4cb4d316e68938d454977d8181a1501445ce6320"; hash = "183qvdh0kb9w4dksqwd94nz9pg188rqnmv2506y6qmi10fi55xw9"; }
    pin = { pkg, rev, hash ? "" }: self: super: {
        ${pkg} = let
            # https://github.com/NixOS/nixpkgs/commit/4cb4d316e68938d454977d8181a1501445ce6320
            pinnedRepo = fetchTarball {
                url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
                sha256 = hash;
            };

            pinnedPkgs = import pinnedRepo {
                inherit (super) system config;
            };

        in pinnedPkgs.${pkg};
    };
}
