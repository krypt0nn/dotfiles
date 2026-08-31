{ username, ... }: {
    programs.throne = {
        enable = true;
        tunMode.enable = true;
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".config/Throne"
        ];
    };
}
