{ ... }: {
    imports = [
        ./hardware.nix
        ./services.nix
        ./virt-manager.nix
        ./steam.nix
    ];

    networking.hostName = "observer-pc";
}
