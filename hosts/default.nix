{ flakeConfig, ... }: {
    imports = ${
        let imports = {
            "observer-pc" = [
                ./observer-pc/hardware.nix
                ./observer-pc/misc.nix
                ./observer-pc/services.nix
            ];
        };

        in imports.${flakeConfig.hostname}
    };
}
