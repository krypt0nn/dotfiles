{ pkgs, ... }:
    let
        prismlauncher-wrapped = pkgs.mkBwrapper {
            imports = [ pkgs.bwrapperPresets.desktop ];

            app = {
                id = "org.prismlauncher.PrismLauncher";

                package = pkgs.prismlauncher.override {
                    jdks = with pkgs; [
                        jdk17_headless
                        jdk21_headless
                    ];
                };
            };

            mounts.readWrite = [
                "$HOME/.local/share/PrismLauncher"
            ];
        };
    in {
        environment.systemPackages = [ prismlauncher-wrapped ];

        environment.persistence."/persistent" = {
            hideMounts = true;

            users.observer = {
                directories = [
                    ".local/share/PrismLauncher"
                ];
            };
        };
    }
