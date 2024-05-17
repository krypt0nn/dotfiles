{ pkgs, ... }: {
    fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        
        liberation_ttf

        jetbrains-mono

        # Windows fonts
        corefonts
    ];
}
