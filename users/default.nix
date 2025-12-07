{ username, ... }:
    let imports = {
        "observer" = ./observer;
    };

    in {
        imports = [
            ./root

            imports.${username}
        ];

        users.mutableUsers = false;
    }
