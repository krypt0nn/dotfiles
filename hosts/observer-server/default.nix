{ ... }: {
    imports = [
        ./hardware.nix
        ./security.nix
        ./services.nix
        ./jellyfin.nix
        ./mjolnir.nix
    ];

    networking.hostName = "observer-server";
}
