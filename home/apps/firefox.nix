{ pkgs, ... }: {
    programs.firefox = {
        enable = true;

        package = pkgs.firefox-wayland;

        policies = {
            HardwareAcceleration = true;
        };
    };
}
