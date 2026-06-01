{ pkgs, ... }: {
    environment.systemPackages = [ pkgs.gimp3 ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
            directories = [
                ".config/GIMP"
            ];
        };
    };
}
