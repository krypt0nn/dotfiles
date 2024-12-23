{ flakeConfig, pkgs, ... }: {
    home.packages = [ pkgs.fragments ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".config/fragments"
        ];
    };
}
