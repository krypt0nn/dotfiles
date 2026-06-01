{ ... }: {
    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
            directories = [
                ".local/share/direnv"
            ];
        };
    };
}
