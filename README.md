# NixOS system configuration

My own NixOS system configuration files.

> Note: while there are instructions for impermanence setup, I'm actually
> planning to get rid of impermanence on all my devices. Currently I introduced
> a stub module and a flag for non-impermanence setups. When I reinstall the
> system on all my devices I will remove impermanence-related documentation
> and code.
>
> If you want to do impermanence setup, I recommend you to think about it twice.
> I used it for 2 years, which is most of my NixOS experience, and I didn't find
> it much practical. Sure it deletes some junk data, but if it's some large
> files then you can easily find them yourself with some terminal commands or
> GUI tools, and if it's some small files then I don't think it's something
> worth caring about.

## Installation

My system is using impermanence setup, i.e. root partition gets wiped every
system restart and restored from nix store and persistent storage partition.
To achieve this, I make root partition a CoW-filesystem's subvolume, and replace
it by an empty snapshot, which is a cheap operation. Some of my devices use
btrfs, while others rely on experimental bcachefs.

We will also make snapshots of root partitions as backups, in case some data
gets wiped before we configure its persistence.

| Subvolume    | Mount         |
| ------------ | ------------- |
| `root`       | `/`           |
| `nix`        | `/nix`        |
| `persistent` | `/persistent` |
| `snapshots`  | `/snapshots`  |

> Note that bcachefs is out of baseline kernel and you will need to build an ISO
> image with bcachefs yourself if you go this route.

### 1. Create base partitions

Lookup main storage drive name with the `lsblk`. Then:

```bash
# Enter interactive sudo mode
sudo -i

# Clear previous partition records from disk
wipefs --all -f /dev/sda1
wipefs --all -f /dev/sda2
wipefs --all -f /dev/sda3

sgdisk --zap-all /dev/sda

# Create boot, swap, and primary partitions
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MB 1GB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary 1GB -16GB
parted /dev/sda -- mkpart swap linux-swap -16GB 100%
```

### 2. Format the partitions

Verify partitions names via said `lsblk` again. Then:

```bash
# Format boot partition
mkfs.fat -F 32 -n boot /dev/sda1

# Format swap partition
mkswap -L swap /dev/sda3

# a) Format primary partition for btrfs
mkfs.btrfs -L nixos /dev/sda2

# b) Format primary partition for bcachefs
bcachefs format \
    --label=t1.nvme1 /dev/sda2 \
    --label=t2.ssd1 /dev/sdb \
    --label=t3.hdd1 /dev/sdc \
    --foreground_target=t1 \
    --promote_target=t2 \
    --background_target=t3 \
    --metadata_target=t3 \
    --metadata_replicas=2 \
    --compression=none \
    --background_compression=zstd \
    --data_replicas=1
```

I'm using 3 storage devices on my PC, so I use bcachefs with devices tiering.
My home server and laptop have only one SSD so I just use btrfs for them.

### 3. Mount created partitions

If we're running btrfs:

```bash
mount /dev/sda2 /mnt

swapon /dev/sda3
```

If we're running bcachefs:

```bash
mount -t bcachefs /dev/sda2:/dev/sdb:/dev/sdc /mnt

swapon /dev/sda3
```

### 4. Create cow subvolumes

If we're running btrfs:

```bash
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@persistent
btrfs subvolume create /mnt/@snapshots
```

If we're running bcachefs:

```bash
bcachefs subvolume create /mnt/@root
bcachefs subvolume create /mnt/@nix
bcachefs subvolume create /mnt/@persistent
bcachefs subvolume create /mnt/@snapshots
```

### 5. Create empty directories within the root subvolume for future mounts

Btrfs requires an existing directory to mount a subvolume into, so we will make
empty directories in root partition before making a snapshot of it, so we will
not need to create this directories every reboot.

```bash
mkdir -p /mnt/root/{boot,nix,persistent,snapshots}
```

### 6. Create blank snapshot of the root subvolume

Create empty snapshot which will be used to restore the clean system state for
impermanence setup.

If we're running btrfs:

```bash
mkdir /mnt/snapshots/root

btrfs subvolume snapshot -r /mnt/@root /mnt/snapshots/root/blank
```

If we're running bcachefs:

```bash
mkdir /mnt/snapshots/root

bcachefs subvolume snapshot -r /mnt/@root /mnt/snapshots/root/blank
```

### 7. Unmount the drive and mount subvolumes instead

If we're running btrfs:

```bash
umount /mnt

mkdir -p /mnt/{boot,nix,persistent,snapshots}

mount -o subvol=@root /dev/sda2 /mnt
mount -o subvol=@nix /dev/sda2 /mnt/nix
mount -o subvol=@persistent /dev/sda2 /mnt/persistent
mount -o subvol=@snapshots /dev/sda2 /mnt/snapshots

mount /dev/sda1 /mnt/boot
```

If we're running bcachefs (subvol option):

> As of Aug 14, 2026, bcachefs doesn't support `subvol` mount option. There is
> a PR in `bcachefs-tools` project to add its support:
> https://github.com/koverstreet/bcachefs-tools/pull/647

```bash
umount /mnt

mkdir -p /mnt/{boot,nix,persistent,snapshots}

mount -t bcachefs -o subvol=@root /dev/sda2:/dev/sdb:/dev/sdc /mnt
mount -t bcachefs -o subvol=@nix /dev/sda2:/dev/sdb:/dev/sdc /mnt/nix
mount -t bcachefs -o subvol=@persistent /dev/sda2:/dev/sdb:/dev/sdc /mnt/persistent
mount -t bcachefs -o subvol=@snapshots /dev/sda2:/dev/sdb:/dev/sdc /mnt/snapshots

mount /dev/sda1 /mnt/boot
```

### 8. Generate basic nixos config

```bash
nixos-generate-config --root /mnt
```

Verify `/mnt/etc/nix/hardware-configuration.nix` file using `vi`. It must
contain mount options for `/nix`, `/persistent`, `/snapshots` and `/` being a
subvolumes (options field), `/boot` being a mount of `/dev/sda1`, and a
swap device `/dev/sda3`.

For bcachefs setup, add the following:

```nix
boot.supportedFilesystems = [ "bcachefs" ];
```

For both btrfs, bcachefs and its binds, add `noatime` and `nodiratime` to mount
options.

Then go to `/mnt/etc/nix/configuration.nix` and:

1. Set `networking.hostName` to a proper value.
2. Set `networking.networkmanager.enable = true;`.
3. In `environment.systemPackages` enable `git`, `curl`, `wget`, `vim` and
   `micro` (more is better right?).
4. Add flakes support with this:
   `nix.settings.experimental-features = [ "nix-command" "flakes" ];`.
5. Allow unfree packages with this: `nixpkgs.config.allowUnfree = true;`.

### 9. Proceed NixOS installation and setup root password afterwards

```bash
nixos-install

reboot
```

### 10. Create password files

Create `root.password` and `user.password` files in the `/persistent` directory
containing your accounts' encrypted passwords.

```bash
sudo -i

mkpasswd -m sha-512 > /persistent/root.password
mkpasswd -m sha-512 > /persistent/user.password
```

### 11. Reproduce this configuration repo

Clone this repo and edit the `flake.nix` file to setup your username and
hostname.

```bash
git clone https://github.com/krypt0nn/dotfiles /system-flake

nixos-rebuild boot --flake /system-flake
```

Don't forget to update `hardware.nix` file (disks UUID-s) for your host device.
Note that after the first restart system can clean all your changes due to
`/persistent` directory initialization.

### 12. Restart the system

```bash
reboot
```

Done. Welcome to your impermanent NixOS system!

## Troubleshooting

### 1. I lost my account! How do I login?

Boot from the live iso used to install the system. Then..

If we're running btrfs:

```bash
sudo -i

mount -o subvol=@root /dev/sda2 /mnt
mount -o subvol=@nix /dev/sda2 /mnt/nix
mount -o subvol=@persistent /dev/sda2 /mnt/persistent

nixos-enter
```

If we're running bcachefs:

```bash
sudo -i

mount -t bcachefs -o subvol=@root /dev/sda2:/dev/sdb:/dev/sdc /mnt
mount -t bcachefs -o subvol=@nix /dev/sda2:/dev/sdb:/dev/sdc /mnt/nix
mount -t bcachefs -o subvol=@persistent /dev/sda2:/dev/sdb:/dev/sdc /mnt/persistent

nixos-enter
```

Also you've probably forgot to create accounts' password files. Check out stage
10.
