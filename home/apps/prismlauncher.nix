{ pkgs, ... }: {
    home.packages = with pkgs; [
        prismlauncher
    ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/PrismLauncher"
        ];
    };
}
