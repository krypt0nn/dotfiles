{ pkgs-unstable, ... }: {
    home.packages = [
        pkgs-unstable.ghostty
    ];

    home.file.".config/ghostty/config".text = builtins.concatStringsSep "\n" [
        "window-width = 90"
        "window-height = 26"
    ];
}
