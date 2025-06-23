{ flakeConfig, pkgs, ... }: {
    home.packages = [ pkgs.amberol ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".cache/amberol"
        ];
    };
}
