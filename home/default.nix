{ pkgs, ... }: {
    imports = [
        # ./theme.nix

        ./observer.nix
    ];

    xdg = {
        userDirs = {
            enable = true;
            createDirectories = true;
        };
    };

    programs.home-manager.enable = true;
    home.stateVersion = "23.11";
}
