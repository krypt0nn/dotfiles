{ pkgs, ... }: {
    environment.systemPackages = [ pkgs.tor-browser ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
            directories = [
                ".tor project"
            ];
        };
    };
}
