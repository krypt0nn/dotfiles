{ flakeConfig, pkgs, ... }: {
    home.packages = with pkgs; [
        fragments
    ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".config/fragments"
        ];
    };
}
