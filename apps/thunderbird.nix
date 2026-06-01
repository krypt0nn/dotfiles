{ pkgs, ... }: {
    environment.systemPackages = [ pkgs.thunderbird ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
            directories = [
                ".thunderbird"
            ];
        };
    };
}
