{ ... }: {
    imports = [
        ./hardware.nix
        ./virt-manager.nix
        ./steam.nix
        ./sleepy-launcher.nix
    ];

    networking.hostName = "observer-pc";
}
