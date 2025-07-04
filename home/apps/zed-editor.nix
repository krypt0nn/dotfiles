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
        load_direnv = "direct";

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

        format_on_save = "off";

        languages = {
            YAML = {
                tab_size = 2;
            };
        };

        lsp = {
            "rust-analyzer" = {
                binary = {
                    path_lookup = true;
                };

                initialization_options = {
                    rust = {
                        # Improves rust-analyzer performance in cost of increased
                        # disk space use.
                        analyzerTargetDir = true;
                    };

                    check = {
                        command = "clippy";
                    };

                    rustfmt = {
                        extraArgs = [
                            "+nightly"
                        ];
                    };
                };
            };
        };

        features = {
            edit_prediction_provider = "none";
        };

        language_models = {
            ollama = {
                api_url = "http://127.0.0.1:11434";
                available_models = [
                    {
                        name = "hf.co/unsloth/Qwen2.5-Coder-7B-Instruct-128K-GGUF:Q4_K_M";
                        display_name = "Qwen 2.5 Coder 7B";
                        max_tokens = 16384;
                        supports_tools = true;
                    }
                ];
            };
        };

        agent = {
            # default_model = {
            #     provider = "zed.dev";
            #     model = "claude-3-7-sonnet-latest";
            # };

            default_model = {
                provider = "ollama";
                model = "hf.co/unsloth/Qwen2.5-Coder-7B-Instruct-128K-GGUF:Q4_K_M";
            };

            version = "2";
        };
    };
}
