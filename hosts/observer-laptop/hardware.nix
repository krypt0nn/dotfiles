{ config, lib, pkgs, modulesPath, ... }: {
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

    	extraModulePackages = [ ];
    };

    fileSystems = {
        "/" = {
            device = "/dev/disk/by-uuid/d4c830ea-7dda-4b87-9901-ecffe81fbb99";
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
            device = "/dev/disk/by-uuid/d4c830ea-7dda-4b87-9901-ecffe81fbb99";
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
            device = "/dev/disk/by-uuid/d4c830ea-7dda-4b87-9901-ecffe81fbb99";
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
            device = "/dev/disk/by-uuid/d4c830ea-7dda-4b87-9901-ecffe81fbb99";
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
            device = "/dev/disk/by-uuid/1CF3-2DF9";
            fsType = "vfat";
            options = [
                "fmask=0022"
                "dmask=0022"
            ];
        };
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/a9e51726-866b-4fcd-b891-6161826e0829"; }
    ];

    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
