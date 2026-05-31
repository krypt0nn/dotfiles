{ pkgs, ... }: {
    # <...>.services.impermanence.path is not enough and the impermanence
    # service doesn't have these binaries. So, we have to specify them here too.
    boot.initrd.systemd.storePaths = with pkgs; [
        btrfs-progs
        coreutils
        util-linux
    ];

    boot.initrd.systemd.services.impermanence = let
      deviceName = "/dev/disk/by-label/nixos";

      # Systemd device unit names replace "/" with "-" and "-" with "\x2d"
      # /dev/disk/by-label/nixos becomes dev-disk-by\x2dlabel-nixos.device
      unitName = "dev-disk-by\\x2dlabel-nixos.device";
    in {
        # wantedBy = [ "initrd.target" ];
        # before = [ "sysroot.mount" ];

        wantedBy = [ "initrd-root-fs.target" ];
        before = [ "sysroot.mount" "initrd-root-fs.target" ];

        after = [ unitName ];
        requires = [ unitName ];

        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";

        path = with pkgs; [
            btrfs-progs
            coreutils
            util-linux
        ];

        script = ''
            set -euo pipefail

            echo "impermanence: mounting base drive"

            mkdir -p /mnt
            mount ${deviceName} /mnt

            if ! btrfs subvolume show /mnt/snapshots/root/blank &>/dev/null; then
                echo "impermanence: blank snapshot missing! aborting root reset"

                umount /mnt
                exit 1
            fi

            echo "impermanence: checking filesystem writability"

            if ! touch /mnt/.write_test 2>/dev/null; then
                echo "impermanence: filesystem became read-only! aborting root reset"

                umount /mnt
                exit 1
            fi

            rm -f /mnt/.write_test

            echo "impermanence: deleting root subvolumes"

            btrfs subvolume list -o /mnt/root | cut -f9 -d' ' |

            while read subvolume; do
                echo "impermanence: deleting /$subvolume subvolume"

                btrfs subvolume delete "/mnt/$subvolume"
            done

            if [ -d "/mnt/snapshots/root/previous" ]; then
                echo "impermanence: deleting previous root subvolume backup"

                btrfs subvolume delete /mnt/snapshots/root/previous
            fi

            echo "impermanence: making backup of the persistent subvolume"

            mkdir -p /mnt/snapshots/persistent
            btrfs subvolume snapshot -r /mnt/persistent /mnt/snapshots/persistent/previous

            echo "impermanence: making backup of the root subvolume"

            mkdir -p /mnt/snapshots/root
            btrfs subvolume snapshot -r /mnt/root /mnt/snapshots/root/previous

            echo "impermanence: deleting root subvolume"

            btrfs subvolume delete /mnt/root

            echo "impermanence: restoring root subvolume from the blank image"

            btrfs subvolume snapshot /mnt/snapshots/root/blank /mnt/root

            echo "impermanence: unmounting base drive"

            umount /mnt

            echo "impermanence: done"
        '';
    };
}
