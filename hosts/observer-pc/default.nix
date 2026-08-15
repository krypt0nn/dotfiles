{ ... }: {
    imports = [
        ./hardware.nix
        ./boot.nix
    ];

    networking.hostName = "observer-pc";
    system.stateVersion = "26.05";
}
