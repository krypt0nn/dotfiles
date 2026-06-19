{ hostname, ... }: {
    imports = let
        desktop = [
            ./amberol.nix
            ./apostrophe.nix
            ./bottles.nix
            ./crosspipe.nix
            ./ghostty.nix
            ./gimp.nix
            ./nixcord.nix
            ./onlyoffice.nix
            ./prismlauncher.nix
            ./qbittorrent.nix
            ./rnote.nix
            ./steam.nix
            ./telegram.nix
            ./throne.nix
            ./thunderbird.nix
            ./zed-editor.nix
            ./zen-browser.nix
        ];
    in {
        "observer-pc" = desktop ++ [
            ./virt-manager.nix
            ./anime-games-launcher.nix
        ];

        "observer-laptop" = desktop;

        "observer-server" = [];
    }.${hostname};
}
