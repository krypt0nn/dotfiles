{ pkgs, ... }: {
    home.packages = [ pkgs.fragments ];

    home.persistence."/persistent" = {
        directories = [
            ".config/fragments"
        ];
    };
}
