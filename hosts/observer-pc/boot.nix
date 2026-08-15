{ pkgs, ... }: {
    boot = {
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };

        # kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
        kernelPackages = pkgs.linuxPackages_latest;

        # De-prioritize using swap.
        kernel.sysctl."vm.swappiness" = 10;

        tmp.cleanOnBoot = true;

        plymouth.enable = true;
    };
}
