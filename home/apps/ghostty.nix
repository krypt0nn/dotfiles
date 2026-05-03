{ pkgs-unstable, ... }: {
    home.packages = [
        pkgs-unstable.ghostty
    ];

    home.file.".config/ghostty/config".text = builtins.concatStringsSep "\n" [
        "window-width = 80"
        "window-height = 32"
        "font-family = monocraft"
    ];
}
