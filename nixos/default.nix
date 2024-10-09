{ flakeConfig, ... }: {
    imports = let imports = rec {
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
                ./desktop.nix
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
                ./bluetooth.nix
                ./misc.nix
                ./services.nix
                ./virtualisation.nix
                ./gnupg.nix
                ./programs.nix
            ];
        };

        in imports.${flakeConfig.hostname};

    system.stateVersion = "23.11";
}
