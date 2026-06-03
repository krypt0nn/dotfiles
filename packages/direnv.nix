{ username, ... }: {
    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".local/share/direnv"
        ];
    };
}
