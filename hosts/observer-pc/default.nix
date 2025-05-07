{ ... }: {
    imports = [
        ./hardware.nix
        ./virt-manager.nix
        ./steam.nix
        ./ollama.nix
    ];

    networking.hostName = "observer-pc";
    system.stateVersion = "24.11";
}
