{ flakeConfig, pkgs, ... }: {
    home.packages = [ pkgs.tor-browser ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".tor project"
        ];
    };
}
