{ flakeConfig, ... }:
    let imports = {
        "observer" = [
            ./observer
        ];
    };

    in {
        imports = imports.${flakeConfig.username};
    }
