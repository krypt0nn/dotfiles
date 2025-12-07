{ hostname, ... }: {
    imports = let imports = {
            "default" = [
                ./nix-config.nix
                ./persistence.nix
                ./boot.nix
                ./drivers.nix
                ./security.nix
                ./network.nix
                ./bluetooth.nix
                ./sound.nix
                ./misc.nix
                ./services.nix
                ./virtualisation.nix
                ./fonts.nix
                ./gnome-desktop.nix
                ./gnupg.nix
                ./programs.nix
            ];

            "observer-pc" = imports.default;
            "observer-laptop" = imports.default;

            "observer-server" = [
                ./nix-config.nix
                ./persistence.nix
                ./boot.nix
                ./drivers.nix
                ./network.nix
                ./bluetooth.nix
                ./misc.nix
                ./services.nix
                ./virtualisation.nix
                ./gnupg.nix
                ./programs.nix
            ];
        };

        in imports.${hostname};
}
