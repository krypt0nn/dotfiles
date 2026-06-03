{ username, ... }: {
    programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        nix-direnv.enable = true;
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".local/share/direnv"
        ];
    };
}
