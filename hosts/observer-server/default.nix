{ ... }: {
    imports = [
        ./hardware.nix
        ./security.nix
        ./jellyfin.nix
    ];

    networking.hostName = "observer-server";
}
