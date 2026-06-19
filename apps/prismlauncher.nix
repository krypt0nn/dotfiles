{ username, pkgs, inputs, ... }:
    let
        # https://github.com/PrismLauncher/Themes
        prismlauncher-themes = pkgs.fetchFromGitHub {
            owner = "PrismLauncher";
            repo = "Themes";
            rev = "9e921ca23a1838f87e0699517a77da5e92921a11";
            hash = "sha256-V6mkItSVA/TSC0yWKvcps/ewAC0nSd1KSBr8Pvdv8z8=";
        };

        mkNixPak = inputs.nixpak.lib.nixpak {
            inherit (pkgs) lib;
            inherit pkgs;
        };

        prismlauncher-wrapped = mkNixPak {
            config = { sloth, ... }: {
                imports = with inputs.nixpak.nixpakModules; [
                    gui-base
                    network
                ];

                app.package = pkgs.prismlauncher.override {
                    jdks = with pkgs; [
                        jdk25_headless
                        jdk21_headless
                        jdk17_headless
                    ];
                };

                flatpak.appId = "org.prismlauncher.PrismLauncher";

                gpu = {
                    enable = true;
                    provider = pkgs.lib.mkForce "nixos";
                };

                bubblewrap = {
                    sockets = {
                        wayland = true;
                        pipewire = true;
                    };

                    bind.ro = [
                        (sloth.concat' sloth.homeDir "/Downloads")
                    ];

                    bind.rw = [
                        sloth.runtimeDir
                        (sloth.concat' sloth.homeDir "/.local/share/PrismLauncher")
                    ];

                    tmpfs = [
                        "/tmp"
                    ];
                };
            };
        };
    in {
        environment.systemPackages = [
            prismlauncher-wrapped.config.env
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
