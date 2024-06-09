{ flakeConfig, ... }: {
    programs.steam.enable = true;

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${flakeConfig.username} = {
            directories = [
                ".steam"
                ".local/share/Steam"
            ];
        };
    };
}
