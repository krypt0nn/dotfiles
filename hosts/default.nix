{ hostname, enableImpermanence, lib, ... }: {
    imports = {
        "observer-pc" = [ ./observer-pc ];
        "observer-laptop" = [ ./observer-laptop ];
        "observer-server" = [ ./observer-server ];
    }.${hostname} ++ (
        # HACK
        lib.optionals enableImpermanence [ ./impermanence.nix ]
    );
}
