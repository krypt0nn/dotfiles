{ username, pkgs, ... }: {
    environment.systemPackages = [ pkgs.zoxide ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".local/share/zoxide"
        ];
    };
}
