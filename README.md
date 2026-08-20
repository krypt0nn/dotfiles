# NixOS system configuration

My NixOS system setup.

## Installation

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

# Format primary partition for bcachefs
bcachefs format \
    --label=t1.nvme1 /dev/sda2 \
    --label=t2.ssd1 /dev/sdb \
    --label=t3.hdd1 /dev/sdc \
    --foreground_target=t1 \
    --promote_target=t2 \
    --background_target=t3 \
    --metadata_target=t3 \
    --data_replicas=1 \
    --metadata_replicas=2 \
    --compression=none \
    --background_compression=lz4
```

### 3. Mount created partitions

```bash
mount -t bcachefs /dev/sda2:/dev/sdb:/dev/sdc /mnt
mount /dev/sda1 /mnt/boot
swapon /dev/sda3
```

### 4. Bootstrap NixOS config

Run this command to generate bootstrap configuration:

```bash
nixos-generate-config --root /mnt
```

Then verify `/mnt/etc/nix/hardware-configuration.nix`:

```nix
boot.supportedFilesystems = [ "bcachefs" ];

fileSystems = {
    "/" = {
        device = "UUID=...";
        fsType = "bcachefs";
        options = [
            "noatime"
            "nodiratime"
        ];
    };

    "/boot" = {
        device = "/dev/disk/by-uuid/...";
        fsType = "vfat";
        options = [
            "fmask=0022"
            "dmask=0022"
        ];
    };
};

swapDevices = [
    { device = "/dev/disk/by-uuid/..."; }
];
```

And `/mnt/etc/nix/configuration.nix`:

```nix
boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
};

# Add the following values:
networking.hostName = ""; # your hostname
networking.networkmanager.enable = true;

environment.systemPackages = with pkgs; [ git curl wget vim micro ];

nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### 5. Install bootstrap NixOS

```bash
nixos-install

reboot
```

### 6. Create password files

After reboot to installed NixOS system create `root.password` and
`username.password` files in the `/etc/secrets` directory containing your
accounts' encrypted passwords.

```bash
sudo -i

mkpasswd -m sha-512 > /etc/secrets/root.password
mkpasswd -m sha-512 > /etc/secrets/username.password
```

### 7. Clone this repository

Clone this repository and edit the `flake.nix` file to setup your username and
hostname.

```bash
mv /etc/nixos /etc/nixos-bak

git clone https://github.com/krypt0nn/dotfiles /etc/nixos
```

Then go to `/etc/nixos/hosts/.../hardware.nix` and update it to much your
`/etc/nixos-bak/hardware-configuration.nix` file.

### 8. Rebuild the system

```bash
nixos-rebuild boot --flake /etc/nixos

reboot
```

Done. Welcome to your impermanent NixOS system!

## Troubleshooting

### 1. I lost my account! How do I login?

Boot from the live iso used to install the system. Then..

```bash
sudo -i

mount -t bcachefs /dev/sda2:/dev/sdb:/dev/sdc /mnt

nixos-enter
```

Also you've probably forgot to create accounts' password files. Check out stage
10.
