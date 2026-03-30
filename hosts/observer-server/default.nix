{ ... }: {
    imports = [
        ./hardware.nix
        ./security.nix
        ./services.nix
        ./jellyfin.nix
    ];

    networking.hostName = "observer-server";
    system.stateVersion = "24.05";
}
