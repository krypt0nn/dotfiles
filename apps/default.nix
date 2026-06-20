{ hostname, ... }: {
    imports = let
        desktop = [
            ./amberol.nix
            ./bottles.nix
            ./ghostty.nix
            ./gimp.nix
            ./nixcord.nix
            ./onlyoffice.nix
            ./qbittorrent.nix
            ./telegram.nix
            ./throne.nix
            ./thunderbird.nix
            ./zed-editor.nix
            ./zen-browser.nix
        ];
    in {
        "observer-pc" = desktop ++ [
            ./rnote.nix
            ./virt-manager.nix
            ./steam.nix
            ./prismlauncher.nix
            ./anime-games-launcher.nix
        ];

        "observer-laptop" = desktop;

        "observer-server" = [];
    }.${hostname};
}
