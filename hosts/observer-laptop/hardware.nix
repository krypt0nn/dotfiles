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

            kernelModules = [
                "kvm-amd"
                "amdgpu"
            ];
        };

        kernelParams = [
            "amd_pstate=active"
            "amdgpu"
        ];

        supportedFilesystems = [ "bcachefs" ];

        zswap = {
            enable = true;
            compressor = "lz4";
        };
    };

    fileSystems = {
        "/" = {
            device = "UUID=c68bbd96-190e-4dbc-b297-94d383c6eca6";
            fsType = "bcachefs";
            options = [
                "noatime"
                "nodiratime"
            ];
        };

        "/boot" = {
            device = "/dev/disk/by-uuid/8831-B12E";
            fsType = "vfat";
            options = [
                "fmask=0022"
                "dmask=0022"
            ];
        };
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/37a1b0ca-6e87-4844-af57-f8752ce61952"; }
    ];

    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
