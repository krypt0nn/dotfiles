{ username, pkgs, ... }: {
    programs.steam = {
        enable = true;
        dedicatedServer.openFirewall = true;

        extraCompatPackages = [
            pkgs.proton-ge-bin
        ];
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
