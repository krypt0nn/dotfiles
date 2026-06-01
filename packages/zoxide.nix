{ pkgs, ... }: {
    environment.systemPackages = [ pkgs.zoxide ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
            directories = [
                ".local/share/zoxide"
            ];
        };
    };
}
