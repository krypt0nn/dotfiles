{ flakeConfig, pkgs, ... }: {
    home.packages = [ pkgs.gimp ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".config/GIMP"
        ];
    };
}
