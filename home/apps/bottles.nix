{ pkgs, ... }: {
    home.packages = [
        (pkgs.bottles.override {
            removeWarningPopup = true;
        })
    ];

    home.persistence."/persistent" = {
        directories = [
            ".local/share/bottles"
        ];
    };
}
