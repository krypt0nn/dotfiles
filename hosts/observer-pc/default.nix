{ ... }: {
    imports = [
        ./hardware.nix
        ./virt-manager.nix
        ./steam.nix
        ./language-models.nix
    ];

    networking.hostName = "observer-pc";
    system.stateVersion = "24.11";
}
