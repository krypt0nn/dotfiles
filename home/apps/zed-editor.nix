{ flakeConfig, pkgs-unstable, ... }: {
    home.packages = [ pkgs-unstable.zed-editor ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/zed"
            ".config/zed"
        ];
    };
}
