{ ... }: {
    imports = [
        ./hardware.nix
        ./security.nix
        ./network.nix
        ./jellyfin.nix
        ./mjolnir.nix
    ];

    networking.hostName = "observer-server";
}
