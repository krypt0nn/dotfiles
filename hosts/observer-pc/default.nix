{ ... }: {
    imports = [
        ./hardware.nix
        ./virt-manager.nix
        ./steam.nix
    ];

    networking.hostName = "observer-pc";
}
