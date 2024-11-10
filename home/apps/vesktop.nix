{ flakeConfig, pkgs, ... }: {
    home.packages = [ pkgs.vesktop ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".config/vesktop"
        ];
    };
}
