{ ... }: {
    imports = [
        ./nix-config.nix
        ./persistence.nix
        ./boot.nix
        ./drivers.nix
        ./security.nix
        ./network.nix
        ./bluetooth.nix
        ./sound.nix
        ./misc.nix
        ./services.nix
        ./virtualisation.nix
        ./fonts.nix
        ./desktop.nix
        ./gnupg.nix
        ./ssh.nix
        ./programs.nix
    ];

    system.stateVersion = "23.11";
}
