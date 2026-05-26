{ ... }: {
    imports = [
        ./hardware.nix
        ./boot.nix
        ./security.nix
        ./services.nix
        ./jellyfin.nix
        ./meshtastic.nix
    ];

    networking.hostName = "observer-server";
    system.stateVersion = "24.05";
}
