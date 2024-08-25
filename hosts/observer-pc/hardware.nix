{ config, lib, pkgs, modulesPath, ... }: {
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

            kernelModules = [ "amdgpu" ];
        };

    	extraModulePackages = [ ];
    };

    fileSystems = {
        "/" = {
            device = "/dev/disk/by-uuid/c488a0f5-e628-400a-a1a3-08840009df1a";
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
            device = "/dev/disk/by-uuid/c488a0f5-e628-400a-a1a3-08840009df1a";
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
            device = "/dev/disk/by-uuid/c488a0f5-e628-400a-a1a3-08840009df1a";
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
            device = "/dev/disk/by-uuid/c488a0f5-e628-400a-a1a3-08840009df1a";
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
            device = "/dev/disk/by-uuid/9F95-2E5E";
            fsType = "vfat";
            options = [
                "fmask=0022"
                "dmask=0022"
            ];
        };
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/22fd323e-aba4-4657-9667-f20b68a06fde"; }
    ];

    zramSwap.enable = true;

    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
