{ pkgs, ... }: {
    home.packages = [ pkgs.gimp3 ];

    home.persistence."/persistent" = {
        directories = [
            ".config/GIMP"
        ];
    };
}
