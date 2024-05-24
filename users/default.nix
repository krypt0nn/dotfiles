{ flakeConfig, ... }: {
    imports = ${
        let imports = {
            "observer" = [
                ./observer
            ];
        };

        in imports.${flakeConfig.username}
    };
}
