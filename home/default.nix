{ inputs, flakeConfig, ... }: {
    imports = let imports = {
            "observer-pc/observer" = [
                # User config
                ./users/observer.nix

                # Packages
                ./packages/direnv.nix
                ./packages/rust.nix

                # Apps
                ./apps/firefox.nix
                ./apps/gimp.nix
                ./apps/onlyoffice.nix

                ./apps/fragments.nix
                ./apps/tor-browser.nix
                ./apps/bottles.nix

                ./apps/vscodium.nix

                ./apps/prismlauncher.nix
                ./apps/aagl.nix
            ];

            "observer-laptop/observer" = [
                # User config
                ./users/observer.nix

                # Packages
                ./packages/direnv.nix
                ./packages/rust.nix

                # Apps
                ./apps/firefox.nix
                ./apps/gimp.nix
                ./apps/onlyoffice.nix

                ./apps/fragments.nix
                ./apps/tor-browser.nix
                ./apps/bottles.nix

                ./apps/vscodium.nix
                ./apps/zed-editor.nix
            ];
        };

        in imports.${flakeConfig.hostname + "/" + flakeConfig.username} ++ [
            inputs.impermanence.nixosModules.home-manager.impermanence
        ];

    xdg.userDirs = {
        enable = true;
        createDirectories = true;
    };

    programs.home-manager.enable = true;

    home.stateVersion = "24.05";
}
