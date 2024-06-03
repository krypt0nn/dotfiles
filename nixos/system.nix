{ ... }: {
    imports = [
        ./boot.nix
        ./drivers.nix
        ./security.nix
        ./sound.nix
        ./misc.nix
        ./services.nix
        ./virtualisation.nix
        ./hosts.nix
        ./nix-config.nix
        ./fonts.nix
        ./desktop.nix
        ./gnupg.nix
        ./programs.nix
    ];

    system.stateVersion = "24.05";
}
