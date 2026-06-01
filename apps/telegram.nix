{ pkgs, ... }: {
    environment.systemPackages = [ pkgs.telegram-desktop ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
            directories = [
                ".local/share/TelegramDesktop"
            ];
        };
    };
}
