{ hostname, ... }: {
    imports = {
        "observer-pc" = [ ./observer-pc ];
        "observer-laptop" = [ ./observer-laptop ];
        "observer-server" = [ ./observer-server ];
    }.${hostname} ++ [
        ./impermanence.nix
        ./syncthing.nix
    ];
}
