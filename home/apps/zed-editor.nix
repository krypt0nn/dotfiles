{ flakeConfig, pkgs-unstable, ... }: {
    home.packages = [ pkgs-unstable.zed-editor ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/zed"
        ];
    };

    home.file.".config/zed/settings.json".text = builtins.toJSON {
        assistant = {
            default_model = {
                provider = "zed.dev";
                model = "claude-3-7-sonnet-latest";
            };

            version = "2";
        };

        features = {
            inline_completion_provider = "copilot";
        };

        telemetry = {
            metrics = false;
            diagnostics = false;
        };

        proxy = "socks5://127.0.0.1:11050";

        vim_mode = false;
        auto_update = false;

        theme = "Andromeda";
        buffer_font_family = "JetBrains Mono";

        ui_font_size = 16;
        buffer_font_size = 16;

        buffer_font_features = {
            calt = true;
            ligatures = true;
        };

        tab_size = 4;
        wrap_guides = [80];
        soft_wrap = "none";

        languages = {
            YAML = {
                tab_size = 2;
            };
        };

        load_direnv = "direct";
        format_on_save = "off";

        lsp = {
            "rust-analyzer" = {
                binary = {
                    path_lookup = true;
                };

                initialization_options = {
                    check = {
                        command = "clippy";
                    };
                };
            };
        };
    };
}
