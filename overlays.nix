{
    # Overlay any package to use a proxy.
    # Example: proxyPackage { pkg = "curl"; }
    proxy = {
        pkg,
        mode ? "https",
        proxy ? "https://localhost:10050",
        ignore ? "127.0.0.1,localhost,::1,.localdomain.com",
        electron ? false
    }: self: super: {
        ${pkg} = super.symlinkJoin {
            name = pkg;
            paths = [ super.${pkg} ];
            buildInputs = [ super.makeWrapper ];
            postBuild = if electron then ''
                wrapProgram $out/bin/${pkg} \
                    --add-flags "--proxy-server=\"${proxy}\"" \
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
