{ username, pkgs, ... }:
    let
        # FIXME: cannot use GPU...
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
        environment.systemPackages = [
            #prismlauncher-wrapped

            (pkgs.prismlauncher.override {
                jdks = with pkgs; [
                    jdk17_headless
                    jdk21_headless
                ];
            })
        ];

        environment.persistence."/persistent" = {
            hideMounts = true;

            users.${username}.directories = [
                ".local/share/PrismLauncher"
            ];
        };
    }
