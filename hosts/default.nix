{ flakeConfig, ... }:
    let imports = {
        "observer-pc"     = ./observer-pc;
        "observer-laptop" = ./observer-laptop;
        "observer-server" = ./observer-server;
    };

    in {
        imports = [
            ./impermanence.nix

            imports.${flakeConfig.hostname}
        ];
    }
