{ config, lib, pkgs, modulesPath, ... }: {
    imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems = {
        "/" = {
            device = "/dev/sda:/dev/sdb:/dev/nvme0n1p3"; # UUID=daddd060-bcc7-4c43-92b7-4fe386b9e875
            fsType = "bcachefs";
            options = [
                "noatime"
                "nodiratime"
                "discard"
                "ssd"
                "compression=lz4"
                "background_compression=zstd"
            ];
        };

        "/boot" = {
            device = "/dev/nvme0n1p1"; # /dev/disk/by-uuid/A07C-1DC5
            fsType = "vfat";
            options = [
                "fmask=0022"
                "dmask=0022"
            ];
        };
    };

    swapDevices = [
        {
            device = "/dev/nvme0n1p2"; # /dev/disk/by-uuid/25bc019c-d826-4499-92d8-d5d97cefc2b3
        }
    ];

    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
