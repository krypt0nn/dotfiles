{ pkgs, ... }: {
    home.packages = [ pkgs.thunderbird ];

    home.persistence."/persistent" = {
        directories = [
            ".thunderbird"
        ];
    };
}
