{ flakeConfig, pkgs-unstable, ... }: {
    home.packages = [ pkgs-unstable.zed-editor ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/zed"
        ];
    };

    home.file.".config/zed/settings.json".text = builtins.toJSON {
        telemetry = {
            metrics = false;
            diagnostics = false;
        };

        proxy = "socks5://127.0.0.1:11050";

        vim_mode = false;
        auto_update = false;

        theme = {
            mode = "system";
            light = "One Light";
            dark = "One Dark";
        };

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

        language_models = {
            ollama = {
                api_url = "http://127.0.0.1:11434";
                available_models = [
                    {
                        name = "qwen2.5-coder:3b";
                        display_name = "Qwen 2.5 Coder 3B";
                        max_tokens = 32768;
                    }
                ];
            };
        };

        assistant = {
            # default_model = {
            #     provider = "zed.dev";
            #     model = "claude-3-7-sonnet-latest";
            # };

            default_model = {
                provider = "ollama";
                model = "qwen2.5-coder:3b";
            };

            version = "2";
        };
    };
}
