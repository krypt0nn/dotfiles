{ flakeConfig, ... }:
    let imports = {
        "observer-pc" = ./observer-pc;
    };

    in {
        imports = [
            ./impermanence.nix

            imports.${flakeConfig.hostname}
        ];
    }
