{ inputs, ... }: {
    imports = [ inputs.anime-games-launcher.nixosModules.anime-games-launcher ];

    programs.anime-games-launcher.enable = true;
}
