{ ... }: {
    imports = [
        ./hardware.nix
        ./security.nix
        ./network.nix
        ./services.nix
        ./jellyfin.nix
        ./mjolnir.nix
    ];

    networking.hostName = "observer-server";
    system.stateVersion = "24.05";
}
