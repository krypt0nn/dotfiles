{ pkgs, ... }: {
    environment.systemPackages = [ pkgs.apostrophe ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
            directories = [
                ".local/share/apostrophe"
            ];
        };
    };
}
