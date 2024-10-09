{ ... }: {
    imports = [
        ./hardware.nix
        ./security.nix
        ./network.nix
        ./jellyfin.nix
    ];

    networking.hostName = "observer-server";
}
