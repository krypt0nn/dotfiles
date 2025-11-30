{ ... }: {
    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableBashIntegration = true;
    };

    home.persistence."/persistent" = {
        directories = [
            ".local/share/direnv"
        ];
    };
}
