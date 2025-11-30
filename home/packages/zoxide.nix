{ ... }: {
    programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
    };

    home.persistence."/persistent" = {
        directories = [
            ".local/share/zoxide"
        ];
    };
}
