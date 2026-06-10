{ username, pkgs, pkgs-unstable, ... }: {
    fonts.packages = with pkgs; [
        open-fonts
        liberation_ttf
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        times-newer-roman

        jetbrains-mono
        monocraft

        # Windows fonts
        pkgs-unstable.vista-fonts
        pkgs-unstable.corefonts
    ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".local/share/fonts"
        ];
    };
}
