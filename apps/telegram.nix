{ username, pkgs, ... }: {
    environment.systemPackages = [ pkgs.telegram-desktop ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".local/share/TelegramDesktop"
        ];
    };
}
