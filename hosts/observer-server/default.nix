{ ... }: {
    imports = [
        ./hardware.nix
        ./security.nix
        ./jellyfin.nix
        ./mjolnir.nix
    ];

    networking.hostName = "observer-server";
}
