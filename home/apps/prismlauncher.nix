{ pkgs, ... }: {
    home.packages = [ pkgs.prismlauncher ];

    home.persistence."/persistent" = {
        directories = [
            ".local/share/PrismLauncher"
        ];
    };
}
