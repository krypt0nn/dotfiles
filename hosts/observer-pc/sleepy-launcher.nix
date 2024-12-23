{ flakeConfig, ... }: {
    programs.sleepy-launcher.enable = true;

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${flakeConfig.username} = {
            directories = [
                ".local/share/sleepy-launcher"
            ];
        };
    };
}
