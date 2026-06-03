{ username, pkgs-unstable, ... }:
    let
        config = builtins.toJSON {
            telemetry = {
                metrics = false;
                diagnostics = false;
            };

            proxy = "socks5://127.0.0.1:1000";
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

            project_panel.dock = "left";
            git_panel.dock = "left";
            agent_panel.dock = "right";
            collaboration_panel.dock = "left";

            format_on_save = "off";

            edit_predictions = {
                disabled_globs = [ "**/*" ];
                provider = "none";
            };

            lsp = {
                "rust-analyzer" = {
                    initialization_options = {
                        rust = {
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
    in {
        environment.systemPackages = [ pkgs-unstable.zed-editor ];

        systemd.tmpfiles.rules = [
            "d /home/${username}/.config/zed 0755 ${username} users -"
            "F /home/${username}/.config/zed/settings.json 0644 ${username} users - ${config}"
        ];

        environment.persistence."/persistent" = {
            hideMounts = true;

            users.${username}.directories = [
                ".local/share/zed"
            ];
        };
    }
