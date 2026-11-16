{ username, pkgs, inputs, ... }:
let
    # HACK: use pinned launcher version before the nixpkgs PR gets merged.
    horizonNixpkgs = fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/d83239b65f3225f5e3c1f368e6442120a6dda242.tar.gz";
        sha256 = "1hr50a5hcidz20f642qhiifg94rrc1q5z9wwlgl8ql6q9d6p2v05";
    };

    horizonPkgs = import horizonNixpkgs {
        inherit (pkgs.stdenv.hostPlatform) system;
        config = pkgs.config;
        overlays = pkgs.overlays or [];
    };

    mkNixPak = inputs.nixpak.lib.nixpak {
        inherit (pkgs) lib;
        inherit pkgs;
    };

    # Upstream is packaged as an FHS environment: the launcher downloads prebuilt
    # Horizon clients and runs them, and those expect an FHS root. The nixpak
    # sandbox therefore wraps the FHS env from the outside (nested bubblewrap).
    horizon-launcher-wrapped = mkNixPak {
        config = { sloth, ... }: {
            imports = with inputs.nixpak.nixpakModules; [
                gui-base
                network
            ];

            app.package = horizonPkgs.horizon-launcher;

            flatpak = {
                appId = "dev.playhorizon.Horizon";
                desktopFile = "horizon-launcher.desktop";
            };

            # Microsoft sign-in is kept in the Secret Service when one answers.
            dbus.policies = {
                "org.freedesktop.secrets" = "talk";
            };

            gpu = {
                enable = true;
                provider = pkgs.lib.mkForce "nixos";
            };

            bubblewrap = {
                env.HORIZON_NO_DISCORD = "1";

                sockets = {
                    wayland = true;
                    pipewire = true;
                };

                bind.ro = [
                    "/run/udev" # gamepads
                    sloth.xdgDownloadDir # modpack and world imports

                    # Prism instances, so imports work without quitting Horizon.
                    (sloth.concat' sloth.xdgDataHome "/PrismLauncher")
                ];

                bind.rw = [
                    sloth.runtimeDir

                    # Launcher data: installed game versions, Minecraft resources.
                    (sloth.concat' sloth.xdgDataHome "/horizon-launcher")

                    # Default game home (instances, saves, screenshots).
                    (sloth.concat' sloth.xdgDataHome "/horizon")

                    # Pointer letting the launcher relocate its folders.
                    (sloth.concat' sloth.xdgConfigHome "/horizon-launcher-location")
                ];

                tmpfs = [
                    "/tmp"
                ];
            };
        };
    };
in {
    environment.systemPackages = [
        horizon-launcher-wrapped.config.env
    ];

    # The sandbox only sees what is bound into it, so these have to exist on the
    # host already: a folder created inside the sandbox is lost when it exits.
    systemd.tmpfiles.rules = [
        "d /home/${username}/.local/share/horizon-launcher 0755 ${username} users -"
        "d /home/${username}/.local/share/horizon 0755 ${username} users -"
        "d /home/${username}/.config/horizon-launcher-location 0755 ${username} users -"
    ];
}
