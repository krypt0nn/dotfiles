{ ... }: {
    imports = [
        ./hardware.nix
    ];

    networking.hostName = "observer-laptop";
}
