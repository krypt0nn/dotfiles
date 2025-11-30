{ pkgs, ... }: {
    home.packages = [ pkgs.onlyoffice-desktopeditors ];

    home.persistence."/persistent" = {
        directories = [
            ".local/share/onlyoffice"
            ".config/onlyoffice"
        ];
    };
}
