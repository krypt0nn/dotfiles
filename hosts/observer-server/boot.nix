{ pkgs, ... }: {
    boot = {
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };

        kernelPackages = pkgs.linuxPackages_latest;

        # De-prioritize using swap.
        kernel.sysctl."vm.swappiness" = 10;

        tmp.cleanOnBoot = true;
    };
}
