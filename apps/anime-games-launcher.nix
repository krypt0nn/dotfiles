{ inputs, username, ... }: {
    imports = [ inputs.anime-games-launcher.nixosModules.anime-games-launcher ];

    programs.anime-games-launcher.enable = true;

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".config/anime-games-launcher"
            ".local/share/anime-games-launcher"
            ".cache/anime-games-launcher"
        ];
    };
}
