{ flakeConfig, pkgs, ... }: {
    home.packages = [ pkgs.thunderbird ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".thunderbird"
        ];
    };
}
