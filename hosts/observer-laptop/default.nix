{ ... }: {
    imports = [
        ./hardware.nix
    ];

    networking.hostName = "observer-laptop";
    system.stateVersion = "24.05";
}
