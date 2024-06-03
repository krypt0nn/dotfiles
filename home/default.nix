{ flakeConfig, ... }: {
    imports = let imports = {
            "observer-pc/observer" = [
                # User config
                ./users/observer.nix

                # Packages
                ./packages/direnv.nix
                ./packages/rust.nix

                # Apps
                ./apps/vscodium.nix
                ./apps/rust-rover.nix

                ./apps/fragments.nix
                ./apps/gimp.nix

                ./apps/prismlauncher.nix
            ];
        };

        in imports.${flakeConfig.hostname + "/" + flakeConfig.username};

    xdg = {
        userDirs = {
            enable = true;
            createDirectories = true;
        };
    };

    programs.home-manager.enable = true;

    home.stateVersion = "24.05";
}
