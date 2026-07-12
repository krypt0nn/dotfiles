{ ... }: {
    imports = [
        ./hardware.nix
        ./boot.nix
        ./security.nix
        ./services.nix
        ./jellyfin.nix
        ./meshtastic.nix
        ./chekist.nix
        ./crow-ci-agent.nix
    ];

    networking.hostName = "observer-server";
    system.stateVersion = "24.05";
}
