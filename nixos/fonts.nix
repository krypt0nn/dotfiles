{ pkgs, pkgs-unstable, ... }: {
    fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        liberation_ttf
        roboto

        jetbrains-mono

        # Windows fonts
        # FIXME: Hello NixOS 24.05, how are you?
        pkgs-unstable.corefonts
    ];
}
