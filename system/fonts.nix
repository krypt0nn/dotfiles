{ pkgs, pkgs-unstable, config, ... }: {
    fonts = {
        enableDefaultPackages = true;
        fontDir.enable = true;

        packages = with pkgs; [
            open-fonts
            liberation_ttf
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts-color-emoji
            times-newer-roman
            adwaita-fonts
            roboto-serif
            roboto-mono

            jetbrains-mono
            nerd-fonts.jetbrains-mono
            monocraft

            # Windows fonts
            pkgs-unstable.vista-fonts
            pkgs-unstable.corefonts
        ];
    };

    # Exposes font packages' font files (symlinked from the read-only store)
    # in ~/.local/share/fonts for apps that scan the user font dir directly.
    systemd.user.services.symlink-fonts = {
        wantedBy = [ "default.target" ];
        serviceConfig.Type = "oneshot";

        script = ''
            rm -rf "$HOME/.local/share/fonts"
            mkdir -p "$HOME/.local/share/fonts"

            for dir in ${toString (map (pkg: "${pkg}/share/fonts") config.fonts.packages)}; do
                if [ -d "$dir" ]; then
                    find "$dir" -type f \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' -o -name '*.otb' -o -name '*.woff' -o -name '*.woff2' \) \
                        -exec ln -s {} "$HOME/.local/share/fonts/" \;
                fi
            done
        '';
    };
}
