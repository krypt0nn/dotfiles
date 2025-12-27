{ hostname, ... }:
    let imports = {
        "observer-pc"     = [ ./observer-pc ./throne.nix ];
        "observer-laptop" = [ ./observer-laptop ./throne.nix ];
        "observer-server" = [ ./observer-server ];
    };

    in {
        imports = imports.${hostname} ++ [
            ./impermanence.nix
        ];
    }
