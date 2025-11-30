{ pkgs, ... }: {
    home.packages = [ pkgs.tor-browser ];

    home.persistence."/persistent" = {
        directories = [
            ".tor project"
        ];
    };
}
