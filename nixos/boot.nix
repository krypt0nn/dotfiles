{ pkgs, ... }: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Reduce swap use (extend SSD lifespan)
    boot.kernel.sysctl = {
        "vm.swappiness" = 10;
    };

    # Enable loading screen
    boot.plymouth = {
        enable = true;

        themePackages = with pkgs; [
            catppuccin-plymouth
        ];

        theme = "catppuccin-macchiato";
    };
}
