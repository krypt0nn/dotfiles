{ pkgs, ... }: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Reduce swap use (extend SSD lifespan)
    boot.kernel.sysctl = {
        "vm.swappiness" = 10;
    };

    boot.supportedFilesystems = ["bcachefs"]; 
}
