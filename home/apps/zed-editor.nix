{ pkgs-unstable, ... }: {
    programs.zed-editor = {
        enable = true;
        package = pkgs-unstable.zed-editor;

        extensions = [
            "rust"
            "toml"
            "xml"
            "nix"
            "lua"
            "luau"
        ];

        userSettings = {
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
            wrap_guides = [ 80 ];
            soft_wrap = "none";

            format_on_save = "off";

            lsp = {
                "rust-analyzer" = {
                    initialization_options = {
                        rust = {
                            # Improves rust-analyzer performance in cost of
                            # increased disk space use.
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
        };
    };

    home.persistence."/persistent" = {
        directories = [
            ".local/share/zed"
        ];
    };
}
