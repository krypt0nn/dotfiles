# NixOS system configuration

My own NixOS system configuration files.

## Installation

We will be cooking impermanent BTRFS NixOS setup here. The core idea is to make
four subvolumes on the disk itself - `root` for `/`, and `nix`, `persistent`
and `snapshots` for `/nix`, `/persistent` and `/snapshots` accordingly. Later on
we will be mounting those subvolumes to the folders inside of the `root` subvolume
using our nixos mounts config.

Value of the `root` subvolume will be overwritten each reboot, while all the other
subvolumes, being outside of `root`, will keep their state. In particular, we're
really interested in `persistent`, which will keep our documents and other important
data saved on the disk between reboots, and `snapshots` which will be used to store
`root` subvolume snapshots to keep track of previously written files. This is needed
to being able to restore some sensitive data if it was forgotten to be persisted.

### 1. Create base partitions

Lookup main storage drive name with the `lsblk`. Then:

```bash
sudo -i

parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary 512MB -16GB
parted /dev/sda -- mkpart swap linux-swap -16GB 100%
```

### 2. Format the partitions

Verify partitions names via said `lsblk` again. Then:

```bash
mkfs.fat -F 32 -n boot /dev/sda1
mkfs.btrfs -L nixos /dev/sda2
mkswap -L swap /dev/sda3
```

### 3. Mount created partitions

```bash
mount /dev/sda2 /mnt
swapon /dev/sda3
```

### 4. Create btrfs subvolumes

```bash
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persistent
btrfs subvolume create /mnt/snapshots
```

### 5. Create empty folders within the root subvolume for future mounts

Later on we will be mounting other btrfs subvolumes to these folders, and root subvolume to the `/`.

```bash
mkdir /mnt/root/boot
mkdir /mnt/root/nix
mkdir /mnt/root/persistent
mkdir /mnt/root/snapshots
```

### 6. Create blank snapshot of the root subvolume

This empty snapshot will be used to restore the clean system state for impermanence setup.

```bash
btrfs subvolume snapshot -r /mnt/root /mnt/snapshots/root/blank
```

### 7. Unmount the drive and mount subvolumes instead

```bash
umount /mnt

mount -o subvol=root /dev/sda2 /mnt
mount -o subvol=nix /dev/sda2 /mnt/nix
mount -o subvol=persistent /dev/sda2 /mnt/persistent
mount -o subvol=snapshots /dev/sda2 /mnt/snapshots

mount /dev/sda1 /mnt/boot
```

### 8. Generate basic nixos config

```bash
nixos-generate-config --root /mnt
```

Verify `/mnt/etc/nix/hardware-configuration.nix` file using `nano`. It must contain mount options
for `/nix`, `/persistent`, `/snapshots` and `/` being a btrfs subvolumes (options field), `/boot` being
a mount of `/dev/sda1`, and a swap device `/dev/sda3`.

Then go to `/mnt/etc/nix/configuration.nix` and:

1. Set `networking.hostname` to a proper value.
2. Set `networking.networkmanager.enable = true;`.
3. In `environment.systemPackages` enable `git`, `curl`, `wget`, `vim` and `micro` (more is better right?).
4. Add flakes support with this: `nix.settings.experimental-features = [ "nix-command" "flakes" ];`.
5. Allow unfree packages with this: `nixpkgs.config.allowUnfree = true;`.

### 9. Proceed NixOS installation and setup root password afterwards

```bash
nixos-install

restart
```

### 10. Reproduce this configuration repo

```bash
sudo git clone https://github.com/krypt0nn/dotfiles /system-flake

sudo nix flake update /system-flake
sudo nixos-rebuild boot --flake /system-flake
```

### 11. Create password files

Create `root.password` and `<your username>.password` files in the `/persistent` folder
containing your accounts' encrypted passwords.

```bash
mkpasswd -m sha-512
```

### 12. Restart the system

```bash
restart
```

Done. Welcome to your impermanent NixOS system!

## Troubleshooting

### 1. I lost my account! How do I login?

Boot from the live iso used to install the system. Then:

```bash
sudo -i

mount -o subvol=root /dev/sda2 /mnt
mount -o subvol=nix /dev/sda2 /mnt/nix
mount -o subvol=persistent /dev/sda2 /mnt/persistent

nixos-enter
```

Also you've probably forgot to create accounts' password files. Check out stage 11.
