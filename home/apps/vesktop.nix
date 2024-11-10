{ flakeConfig, pkgs, ... }: {
    home.packages = with pkgs; [
        vesktop
    ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".config/vesktop"
        ];
    };
}
