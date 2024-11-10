{ flakeConfig, pkgs, ... }: {
    home.packages = [ pkgs.bottles ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/bottles"
        ];
    };
}
