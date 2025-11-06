{ ... }: {
    imports = [
        ./hardware.nix
        ./security.nix
        ./network.nix
        ./services.nix
        ./jellyfin.nix
        ./mjolnir.nix
        ./ollama.nix
    ];

    networking.hostName = "observer-server";
    system.stateVersion = "24.05";
}
