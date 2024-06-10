{ pkgs, pkgs-unstable, ... }: {
    fonts.packages = with pkgs; [
        open-fonts
        liberation_ttf
        noto-fonts-emoji
        times-newer-roman

        jetbrains-mono

        # Windows fonts
        pkgs-unstable.corefonts
        pkgs-unstable.vistafonts
    ];
}
