{ hostname, enableImpermanence, lib, ... }: {
    imports = let
        default = [
            ./nix-config.nix
            ./users.nix
            ./drivers.nix
            ./security.nix
            ./network.nix
            ./bluetooth.nix
            ./services.nix
            ./virtualisation.nix
            ./gnupg.nix
            ./programs.nix
        ] ++ (
            # HACK
            lib.optionals enableImpermanence [ ./persistence.nix ]
        );

        desktop = default ++ [
            ./gnome-desktop.nix
            ./sound.nix
            ./fonts.nix
        ];
    in {
        "observer-pc"     = desktop;
        "observer-laptop" = desktop;
        "observer-server" = default;
    }.${hostname};
}
