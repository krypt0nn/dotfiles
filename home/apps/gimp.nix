{ flakeConfig, pkgs, ... }: {
    home.packages = [ pkgs.gimp3 ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".config/GIMP"
        ];
    };
}
