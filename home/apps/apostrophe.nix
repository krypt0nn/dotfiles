{ pkgs, ... }: {
    home.packages = [ pkgs.apostrophe ];

    home.persistence."/persistent" = {
        directories = [
            ".local/share/apostrophe"
        ];
    };
}
