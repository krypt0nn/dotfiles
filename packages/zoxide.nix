{ username, ... }: {
    programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".local/share/zoxide"
        ];
    };
}
