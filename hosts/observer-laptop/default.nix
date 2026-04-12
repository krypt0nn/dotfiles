{ ... }: {
    imports = [
        ./hardware.nix
        ./boot.nix
        ./network.nix
    ];

    networking.hostName = "observer-laptop";
    system.stateVersion = "24.05";
}
