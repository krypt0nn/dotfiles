{ flakeConfig, pkgs, ... }: {
    home.packages = with pkgs; [
        onlyoffice-bin
    ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/onlyoffice"
            ".config/onlyoffice"
        ];
    };
}
