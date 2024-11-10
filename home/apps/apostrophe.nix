{ flakeConfig, pkgs, ... }: {
    home.packages = [ pkgs.apostrophe ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/apostrophe"
        ];
    };
}
