{ ... }: {
    imports = [
        ./hardware.nix
        ./boot.nix
        ./network.nix
    ];

    networking.hostName = "observer-laptop";
    system.stateVersion = "26.05";
}
