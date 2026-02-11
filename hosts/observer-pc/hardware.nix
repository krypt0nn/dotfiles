{ config, lib, modulesPath, ... }: {
    imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
        initrd = {
            availableKernelModules = [
                "nvme"
                "xhci_pci"
                "ahci"
                "usb_storage"
                "usbhid"
                "sd_mod"
            ];

            kernelModules = [
                "amdgpu"
                "ntsync"
            ];
        };

        kernelParams = [
            "amd_pstate=active"
            "amdgpu"
        ];

        extraModulePackages = [];

        plymouth.enable = true;
    };

    fileSystems = {
        "/" = {
            device = "/dev/disk/by-uuid/4740ea8c-ecab-417a-bf0a-0d14de06b058";
            fsType = "btrfs";
            options = [
                "noatime"
                "nodiratime"
                "ssd"
                "subvol=root"
            ];
            neededForBoot = true;
        };

        "/nix" = {
            device = "/dev/disk/by-uuid/4740ea8c-ecab-417a-bf0a-0d14de06b058";
            fsType = "btrfs";
            options = [
                "noatime"
                "nodiratime"
                "ssd"
                "compress=zstd"
                "subvol=nix"
            ];
            neededForBoot = true;
        };

        "/persistent" = {
            device = "/dev/disk/by-uuid/4740ea8c-ecab-417a-bf0a-0d14de06b058";
            fsType = "btrfs";
            options = [
                "noatime"
                "nodiratime"
                "ssd"
                "subvol=persistent"
            ];
            neededForBoot = true;
        };

        "/snapshots" = {
            device = "/dev/disk/by-uuid/4740ea8c-ecab-417a-bf0a-0d14de06b058";
            fsType = "btrfs";
            options = [
                "noatime"
                "nodiratime"
                "ssd"
                "subvol=snapshots"
            ];
            neededForBoot = true;
        };

        "/boot" = {
            device = "/dev/disk/by-uuid/36C0-08DE";
            fsType = "vfat";
            options = [
                "fmask=0022"
                "dmask=0022"
            ];
            neededForBoot = true;
        };
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/08adb28a-60a0-4d18-8d6f-1e7f1e4e92e1"; }
    ];

    zramSwap.enable = true;

    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
