{ username, ... }: {
    programs.steam = {
        enable = true;
        dedicatedServer.openFirewall = true;
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username} = {
            directories = [
                ".steam"
                ".local/share/Steam"
            ];
        };
    };
}
