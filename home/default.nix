{ inputs, flakeConfig, ... }: {
    imports = let imports = {
            "observer-pc/observer" = [
                # User config
                ./users/observer.nix

                # Packages
                ./packages/fish.nix
                ./packages/fzf.nix
                ./packages/zoxide.nix
                ./packages/direnv.nix
                ./packages/rust.nix

                # Apps
                ./apps/zen-browser.nix
                ./apps/telegram.nix
                ./apps/vesktop.nix
                ./apps/gimp.nix
                ./apps/onlyoffice.nix
                ./apps/apostrophe.nix
                ./apps/hieroglyphic.nix
                ./apps/rnote.nix

                ./apps/fragments.nix
                ./apps/tor-browser.nix
                ./apps/bottles.nix

                ./apps/zed-editor.nix

                ./apps/prismlauncher.nix
            ];

            "observer-laptop/observer" = [
                # User config
                ./users/observer.nix

                # Packages
                ./packages/fish.nix
                ./packages/fzf.nix
                ./packages/zoxide.nix
                ./packages/direnv.nix
                ./packages/rust.nix

                # Apps
                ./apps/zen-browser.nix
                ./apps/telegram.nix
                ./apps/vesktop.nix
                ./apps/gimp.nix
                ./apps/onlyoffice.nix
                ./apps/apostrophe.nix
                ./apps/hieroglyphic.nix

                ./apps/fragments.nix
                ./apps/tor-browser.nix
                ./apps/bottles.nix

                ./apps/zed-editor.nix
            ];

            "observer-server/observer" = [
                # User config
                ./users/observer.nix

                # Packages
                ./packages/fish.nix
                ./packages/fzf.nix
                ./packages/zoxide.nix
                ./packages/direnv.nix
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
