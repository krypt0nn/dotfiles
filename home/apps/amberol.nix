{ pkgs, ... }: {
    home.packages = [ pkgs.amberol ];

    home.persistence."/persistent" = {
        directories = [
            ".cache/amberol"
        ];
    };
}
