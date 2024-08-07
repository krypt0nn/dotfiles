{ flakeConfig, ... }: {
    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableBashIntegration = true;
    };

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/direnv"
        ];
    };
}
