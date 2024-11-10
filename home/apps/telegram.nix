{ flakeConfig, pkgs, ... }: {
    home.packages = with pkgs; [
        telegram-desktop
    ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/TelegramDesktop"
        ];
    };
}
