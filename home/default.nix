{ pkgs, flakeConfig, ... }: {
    imports = let imports = {
            "observer-pc/observer" = [
                ./users/observer.nix
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
    home.stateVersion = "23.11";
}
