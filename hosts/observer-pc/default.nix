{ ... }: {
    imports = [
        ./hardware.nix
        ./services.nix
        ./steam.nix
    ];

    networking.hostName = "observer-pc";
}
