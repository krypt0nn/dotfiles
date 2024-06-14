{ ... }: {
    imports = [
        ./hardware.nix
        ./jellyfin.nix
        ./virt-manager.nix
        ./steam.nix
    ];

    networking.hostName = "observer-pc";
}
