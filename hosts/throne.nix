{ username, pkgs-unstable, ... }: {
    programs.throne = {
        enable = true;
        package = pkgs-unstable.throne;
        tunMode.enable = true;
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username} = {
            directories = [
                ".config/Throne"
            ];
        };
    };
}
