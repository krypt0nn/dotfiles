{ flakeConfig, ... }:
    let imports = {
        "observer-pc" = ./observer-pc;
        "observer-laptop" = ./observer-laptop;
    };

    in {
        imports = [
            ./impermanence.nix

            imports.${flakeConfig.hostname}
        ];
    }
