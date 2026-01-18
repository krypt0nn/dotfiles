{ pkgs, ... }: {
    home.packages = [
        (pkgs.prismlauncher.override {
            jdks = with pkgs; [
                jdk21_headless
            ];
        })
    ];

    home.persistence."/persistent" = {
        directories = [
            ".local/share/PrismLauncher"
        ];
    };
}
