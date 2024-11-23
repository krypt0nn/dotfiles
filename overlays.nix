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
}
