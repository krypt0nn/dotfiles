{ hostname, ... }: {
    imports = let
        default = [
            ./nix-config.nix
            ./persistence.nix
            ./drivers.nix
            ./security.nix
            ./network.nix
            ./bluetooth.nix
            ./sound.nix
            ./misc.nix
            ./services.nix
            ./virtualisation.nix
            ./fonts.nix
            ./gnome-desktop.nix
            ./gnupg.nix
            ./programs.nix
        ];
    in {
        "observer-pc"     = default;
        "observer-laptop" = default;
        "observer-server" = [
            ./nix-config.nix
            ./persistence.nix
            ./drivers.nix
            ./network.nix
            ./bluetooth.nix
            ./misc.nix
            ./services.nix
            ./virtualisation.nix
            ./gnupg.nix
            ./programs.nix
        ];
    }.${hostname};
}
