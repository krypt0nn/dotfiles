{ flakeConfig, pkgs, ... }: {
    home.packages = [ pkgs.flowblade ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/flowblade"
            ".config/flowblade"
        ];
    };
}
