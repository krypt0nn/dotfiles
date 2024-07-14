{ flakeConfig, pkgs-unstable, ... }: {
    home.packages = with pkgs-unstable; [
        zed-editor
    ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/zed"
            ".config/zed"
        ];
    };
}
