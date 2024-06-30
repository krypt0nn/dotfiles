{ flakeConfig, pkgs, ... }: {
    home.packages = with pkgs; [
        bottles
    ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/bottles"
        ];
    };
}
