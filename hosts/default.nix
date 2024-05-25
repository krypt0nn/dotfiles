{ flakeConfig, ... }:
    let imports = {
        "observer-pc" = ./observer-pc;
    };

    in {
        imports = [ imports.${flakeConfig.hostname} ];
    }
