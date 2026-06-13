{ username, pkgs, ... }: {
    programs.throne = {
        enable = true;
        package = pkgs.throne;
        tunMode.enable = true;
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".config/Throne"
        ];
    };
}
