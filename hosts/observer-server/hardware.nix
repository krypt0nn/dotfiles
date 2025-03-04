{ config, lib, modulesPath, ... }: {
    imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
        initrd = {
            availableKernelModules = [
                "nvme"
                "xhci_pci"
                "usb_storage"
                "sd_mod"
            ];

            kernelModules = [ "amdgpu" ];
        };

        kernelParams = [
            "amd_pstate=active"
            "amdgpu"
        ];

        extraModulePackages = [];
    };

    fileSystems = {
        "/" = {
            device = "/dev/disk/by-uuid/29fdc842-3082-4484-9a00-8df1ab098b1c";
            fsType = "btrfs";
            options = [
                "noatime"
                "nodiratime"
                "ssd"
                "compress=lzo"
                "subvol=root"
            ];
        };

        "/nix" = {
            device = "/dev/disk/by-uuid/29fdc842-3082-4484-9a00-8df1ab098b1c";
            fsType = "btrfs";
            options = [
                "noatime"
                "nodiratime"
                "ssd"
                "compress=lzo"
                "subvol=nix"
            ];
        };

        "/persistent" = {
            device = "/dev/disk/by-uuid/29fdc842-3082-4484-9a00-8df1ab098b1c";
            fsType = "btrfs";
            options = [
                "noatime"
                "nodiratime"
                "ssd"
                "compress=lzo"
                "subvol=persistent"
            ];
            neededForBoot = true;
        };

        "/snapshots" = {
            device = "/dev/disk/by-uuid/29fdc842-3082-4484-9a00-8df1ab098b1c";
            fsType = "btrfs";
            options = [
                "noatime"
                "nodiratime"
                "ssd"
                "compress=lzo"
                "subvol=snapshots"
            ];
            neededForBoot = true;
        };

        "/boot" = {
            device = "/dev/disk/by-uuid/3EE9-88BE";
            fsType = "vfat";
            options = [
                "fmask=0022"
                "dmask=0022"
            ];
        };

        "/storage" = {
            device = "/dev/disk/by-uuid/F7EF-B07D";
            fsType = "exfat";
            options = [
                "noatime"
                "nodiratime"
            ];
        };
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/8172e6a1-8281-4ebb-ab9e-5c1f2b74ce57"; }
    ];

    zramSwap.enable = true;

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
