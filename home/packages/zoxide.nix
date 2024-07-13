{ flakeConfig, ... }: {
    programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
    };

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/zoxide"
        ];
    };
}
