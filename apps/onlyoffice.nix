{ username, pkgs, config, ... }: {
    environment.systemPackages = [ pkgs.onlyoffice-desktopeditors ];

    systemd.user.services.onlyoffice-fonts = {
        wantedBy = [ "default.target" ];
        serviceConfig.Type = "oneshot";

        script = ''
            mkdir -p "$HOME/.local/share/fonts"

            for dir in ${toString (map (pkg: "${pkg}/share/fonts") config.fonts.packages)}; do
                if [ -d "$dir" ]; then
                    find "$dir" -type f \( -name '*.ttf' -o -name '*.otf' -o -name '*.woff' -o -name '*.woff2' \) \
                        -exec cp -n {} "$HOME/.local/share/fonts/" \;
                fi
            done

            chmod 544 "$HOME/.local/share/fonts" 2>/dev/null || true
            chmod 444 "$HOME/.local/share/fonts/"* 2>/dev/null || true
        '';
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".local/share/onlyoffice"
            ".config/onlyoffice"
        ];
    };
}
