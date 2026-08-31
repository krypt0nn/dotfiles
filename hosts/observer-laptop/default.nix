{ ... }: {
    imports = [
        ./hardware.nix
        ./boot.nix
    ];

    networking.hostName = "observer-laptop";
    system.stateVersion = "26.05";
}
