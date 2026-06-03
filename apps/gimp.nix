{ username, pkgs, ... }: {
    environment.systemPackages = [ pkgs.gimp3 ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".config/GIMP"
        ];
    };
}
