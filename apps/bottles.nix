{ username, pkgs, inputs, ... }:
    let
        mkNixPak = inputs.nixpak.lib.nixpak {
            inherit (pkgs) lib;
            inherit pkgs;
        };

        bottles-wrapped = mkNixPak {
            config = { sloth, ... }: {
                imports = with inputs.nixpak.nixpakModules; [
                    gui-base
                    network
                ];

                app.package = pkgs.bottles.override {
                    removeWarningPopup = true;

                    # Source: https://github.com/NixOS/nixpkgs/blob/a0374025a863d007d98e3297f6aa46cc3141c2f0/pkgs/by-name/bo/bottles-unwrapped/package.nix#L101-L119
                    extraPkgs = pkgs': with pkgs'; [
                        cabextract
                        p7zip
                        xdpyinfo
                        imagemagick
                        vkbasalt-cli
                        vulkan-tools

                        gamemode
                        gamescope
                        mangohud
                        vmtouch
                        fvs2

                        lsb-release
                        pciutils
                        procps
                    ];
                };

                flatpak.appId = "com.usebottles.bottles";

                dbus.policies = {
                    "com.feralinteractive.GameMode" = "talk";
                };

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
                        "/run/udev"
                        (sloth.concat' sloth.homeDir "/Downloads")
                    ];

                    bind.rw = [
                        sloth.runtimeDir
                        (sloth.concat' sloth.homeDir "/.local/share/bottles")
                    ];

                    tmpfs = [
                        "/tmp"
                    ];
                };
            };
        };
    in {
        environment.systemPackages = [
            bottles-wrapped.config.env
        ];

        programs.gamemode.enable = true;

        environment.persistence."/persistent" = {
            hideMounts = true;

            users.${username}.directories = [
                ".local/share/bottles"
            ];
        };
    }
