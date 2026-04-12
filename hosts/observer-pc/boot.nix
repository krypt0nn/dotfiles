{ pkgs, ... }: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;
    # boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;

    # Reduce swap use (extend SSD lifespan)
    boot.kernel.sysctl = {
        "vm.swappiness" = 10;
    };

    # Mount tmpfs in /tmp
    boot.tmp.useTmpfs = true;
}
