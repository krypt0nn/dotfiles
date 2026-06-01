{ pkgs, ... }: {
    environment.systemPackages = [ pkgs.onlyoffice-desktopeditors ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
            directories = [
                ".local/share/onlyoffice"
                ".config/onlyoffice"
            ];
        };
    };
}
