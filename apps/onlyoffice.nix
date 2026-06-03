{ username, pkgs, ... }: {
    environment.systemPackages = [ pkgs.onlyoffice-desktopeditors ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".local/share/onlyoffice"
            ".config/onlyoffice"
        ];
    };
}
