{ flakeConfig, ... }:
    let imports = {
        "observer-pc" = [
            ./observer-pc/hardware.nix
            ./observer-pc/misc.nix
            ./observer-pc/services.nix
        ];
    };

    in {
        imports = imports.${flakeConfig.hostname};
    }
