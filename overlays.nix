{
    # Overlay any package to use a proxy.
    # Example: proxy { pkg = "curl"; }
    proxy = {
        pkg,
        mode ? "https",
        proxy ? "socks5://127.0.0.1:9050",
        ignore ? "127.0.0.1,::1,localhost,.localdomain.com",
        electron ? false
    }: self: super: {
        ${pkg} = super.symlinkJoin {
            name = pkg;
            paths = [ super.${pkg} ];
            buildInputs = [ super.makeWrapper ];
            postBuild = if electron then ''
                wrapProgram $out/bin/${pkg} \
                    --add-flags "--proxy-server=\"${proxy}\"" \
                    --set ${super.lib.strings.toLower mode}_proxy ${proxy} \
                    --set ${super.lib.strings.toUpper mode}_PROXY ${proxy} \
                    --set no_proxy "${ignore}"
            '' else ''
                wrapProgram $out/bin/${pkg} \
                    --set ${super.lib.strings.toLower mode}_proxy ${proxy} \
                    --set ${super.lib.strings.toUpper mode}_PROXY ${proxy} \
                    --set no_proxy "${ignore}"
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
