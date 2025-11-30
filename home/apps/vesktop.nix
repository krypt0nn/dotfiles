{ pkgs, ... }: {
    home.packages = [ pkgs.vesktop ];

    home.persistence."/persistent" = {
        directories = [
            ".config/vesktop"
        ];
    };
}
