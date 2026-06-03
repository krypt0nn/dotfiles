{ username, pkgs, ... }: {
    environment.systemPackages = [ pkgs.thunderbird ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".thunderbird"
        ];
    };
}
