{ pkgs, ... }: {
    home.packages = [ pkgs.telegram-desktop ];

    home.persistence."/persistent" = {
        directories = [
            ".local/share/TelegramDesktop"
        ];
    };
}
