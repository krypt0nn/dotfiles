{ flakeConfig, pkgs, ... }: {
    home.packages = [
        (pkgs.bottles.override {
            removeWarningPopup = true;
        })
    ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/bottles"
        ];
    };
}
