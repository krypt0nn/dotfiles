{ flakeConfig, ... }:
    let imports = {
        "observer" = ./observer;
    };

    in {
        imports = [
            ./root

            imports.${flakeConfig.username}
        ];

        users.mutableUsers = false;
    }
