{ flakeConfig, pkgs, ... }: {
    home.packages = [ pkgs.prismlauncher ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/PrismLauncher"
        ];
    };
}
