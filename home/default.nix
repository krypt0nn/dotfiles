{ inputs, hostname, username, ... }: {
    imports = let imports = {
            "observer@observer-pc" = [
                # User config
                ./users/observer.nix

                # Packages
                ./packages/fish.nix
                ./packages/fzf.nix
                ./packages/zoxide.nix
                ./packages/direnv.nix
                ./packages/rust.nix

                # Apps
                ./apps/ghostty.nix
                ./apps/zen-browser.nix
                ./apps/telegram.nix
                ./apps/nixcord.nix
                ./apps/amberol.nix
                ./apps/gimp.nix
                ./apps/onlyoffice.nix
                ./apps/apostrophe.nix
                ./apps/thunderbird.nix
                ./apps/rnote.nix

                ./apps/qbittorrent.nix
                ./apps/tor-browser.nix
                ./apps/bottles.nix

                ./apps/zed-editor.nix

                ./apps/prismlauncher.nix
            ];

            "observer@observer-laptop" = [
                # User config
                ./users/observer.nix

                # Packages
                ./packages/fish.nix
                ./packages/fzf.nix
                ./packages/zoxide.nix
                ./packages/direnv.nix
                ./packages/rust.nix

                # Apps
                ./apps/ghostty.nix
                ./apps/zen-browser.nix
                ./apps/telegram.nix
                ./apps/nixcord.nix
                ./apps/amberol.nix
                ./apps/gimp.nix
                ./apps/onlyoffice.nix
                ./apps/apostrophe.nix
                ./apps/thunderbird.nix

                ./apps/qbittorrent.nix
                ./apps/tor-browser.nix
                ./apps/bottles.nix

                ./apps/zed-editor.nix
            ];

            "observer@observer-server" = [
                # User config
                ./users/observer.nix

                # Packages
                ./packages/fish.nix
                ./packages/fzf.nix
                ./packages/zoxide.nix
                ./packages/direnv.nix
            ];
        };

        in imports."${username}@${hostname}" ++ [
            inputs.nixcord.homeModules.nixcord
        ];

    xdg.userDirs = {
        enable = true;
        createDirectories = true;
    };

    programs.home-manager.enable = true;

    home.stateVersion = "24.05";
}
