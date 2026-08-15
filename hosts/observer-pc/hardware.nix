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
                "kvm-amd"
                "amdgpu"
                "ntsync"
            ];
        };

        kernelParams = [
            "amd_pstate=active"
            "amdgpu"
        ];

        supportedFilesystems = [ "bcachefs" ];
    };

    fileSystems = {
        "/" = {
            device = "UUID=1fc1d6b2-8507-4e98-88ce-c29a33820e8b";
            fsType = "bcachefs";
            options = [
                "noatime"
                "nodiratime"
            ];
        };

        "/boot" = {
            device = "/dev/disk/by-uuid/A937-55E6";
            fsType = "vfat";
            options = [
                "fmask=0022"
                "dmask=0022"
            ];
        };
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/6778d8f4-7b66-494b-8001-6b3cab57e75b"; }
    ];

    zramSwap.enable = true;

    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
