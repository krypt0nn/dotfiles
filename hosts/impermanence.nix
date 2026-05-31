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
        enable = true;

        wantedBy = [ "initrd.target" ];
        before = [ "sysroot.mount" ];

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

            # Ensure /mnt is always unmounted, even on error
            trap 'umount /mnt 2>/dev/null || true' EXIT

            # Mount btrfs into /mnt

            echo "impermanence: mounting base drive"

            mkdir -p /mnt
            mount ${deviceName} /mnt

            if ! btrfs subvolume show /mnt/snapshots/root/blank &>/dev/null; then
                echo "impermanence: blank snapshot missing! aborting root reset"

                umount /mnt
                exit 1
            fi

            # Check mounted filesystem into being write-able
            # It can be mounted as read-only if there was some filesystem error

            echo "impermanence: checking filesystem writability"

            if ! touch /mnt/.write_test 2>/dev/null; then
                echo "impermanence: filesystem became read-only! aborting root reset"

                umount /mnt
                exit 1
            fi

            rm -f /mnt/.write_test

            # Delete temporary btrfs subvolumes created by... systemd?

            echo "impermanence: deleting root subvolumes"

            while read -r subvolume; do
                echo "impermanence: deleting /$subvolume subvolume"

                btrfs subvolume delete "/mnt/$subvolume"
            done < <(btrfs subvolume list -o /mnt/root | cut -f9 -d' ')

            # Delete previous persistent subvolume backup and make a new one

            if [ -d "/mnt/snapshots/persistent/previous" ]; then
                echo "impermanence: deleting previous persistent subvolume backup"

                btrfs subvolume delete /mnt/snapshots/persistent/previous
            fi

            echo "impermanence: making backup of the persistent subvolume"

            mkdir -p /mnt/snapshots/persistent
            btrfs subvolume snapshot -r /mnt/persistent /mnt/snapshots/persistent/previous

            # Delete previous root subvolume backup and make a new one

            if [ -d "/mnt/snapshots/root/previous" ]; then
                echo "impermanence: deleting previous root subvolume backup"

                btrfs subvolume delete /mnt/snapshots/root/previous
            fi

            echo "impermanence: making backup of the root subvolume"

            mkdir -p /mnt/snapshots/root
            btrfs subvolume snapshot -r /mnt/root /mnt/snapshots/root/previous

            # Delete current root subvolume and replace it by a blank one

            echo "impermanence: deleting root subvolume"

            btrfs subvolume delete /mnt/root

            echo "impermanence: restoring root subvolume from the blank image"

            btrfs subvolume snapshot /mnt/snapshots/root/blank /mnt/root

            # Unmount btrfs, allowing it to be mounted as root partition

            echo "impermanence: unmounting base drive"

            umount /mnt

            echo "impermanence: done"
        '';
    };
}
