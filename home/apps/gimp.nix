{ flakeConfig, pkgs, ... }: {
    home.packages = with pkgs; [
        gimp
    ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".vscode-oss"
            ".config/GIMP"
        ];
    };
}
