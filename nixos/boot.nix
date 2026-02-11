{ pkgs, ... }: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Reduce swap use (extend SSD lifespan)
    boot.kernel.sysctl = {
        "vm.swappiness" = 10;
    };

    # Mount tmpfs in /tmp
    boot.tmp.useTmpfs = true;
}
