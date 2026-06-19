{ username, pkgs, ... }:
    let
        # https://github.com/PrismLauncher/Themes
        prismlauncher-themes = pkgs.fetchFromGitHub {
            owner = "PrismLauncher";
            repo = "Themes";
            rev = "9e921ca23a1838f87e0699517a77da5e92921a11";
            hash = "sha256-V6mkItSVA/TSC0yWKvcps/ewAC0nSd1KSBr8Pvdv8z8=";
        };

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
                    jdk25_headless
                    jdk21_headless
                    jdk17_headless
                ];
            })
        ];

        systemd.tmpfiles.rules = [
            "d /home/${username}/.local/share/PrismLauncher 0755 ${username} users -"
            "L+ /home/${username}/.local/share/PrismLauncher/themes - - - - ${prismlauncher-themes}/themes"
            "L+ /home/${username}/.local/share/PrismLauncher/iconthemes - - - - ${prismlauncher-themes}/icons"
        ];

        environment.persistence."/persistent" = {
            hideMounts = true;

            users.${username}.directories = [
                ".local/share/PrismLauncher"
            ];
        };
    }
