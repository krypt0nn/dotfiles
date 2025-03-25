{ flakeConfig, lib, pkgs, ... }: {
    programs.fish = {
        enable = true;

        # Disable fish greeting
        shellInit = "set fish_greeting";

        plugins = with pkgs.fishPlugins; [
            # p10k-like prompt
            # Use `tide configure` for initial setup
            { name = "tide"; src = tide.src; }

            # Better "cd" implementation
            { name = "z"; src = z.src; }

            # Filter failed commands from the history
            { name = "sponge"; src = sponge.src; }

            # Fuzzy finder support for fish
            { name = "fzf-fish"; src = fzf-fish.src; }
        ];

        shellAliases = {
            system-allow-edit = lib.concatStrings [
                "sudo chown -R ${flakeConfig.username} /system-flake && "
                "sudo chmod -R 755 /system-flake"
            ];

            system-forbid-edit = lib.concatStrings [
                "sudo chown -R root /system-flake && "
                "sudo chmod -R 755 /system-flake && "
                "sudo chown -R ${flakeConfig.username} /system-flake/.git && "
                "sudo chmod -R 755 /system-flake/.git"
            ];

            system-update = "sudo nixos-rebuild switch --flake /system-flake";
            system-upgrade = "sudo nix flake update --flake /system-flake && sudo nixos-rebuild boot --flake /system-flake";

            system-diff = lib.concatStrings [
                "nix store diff-closures "
                "$(find /nix/var/nix/profiles -type l -regex '.*/system-.*-link' -print | tail -n 2 | head -n 1) "
                "$(find /nix/var/nix/profiles -type l -regex '.*/system-.*-link' -print | tail -n 1) | "
                "fzf"
            ];

            system-diff-running = lib.concatStrings [
                "nix store diff-closures "
                "/run/current-system "
                "$(find /nix/var/nix/profiles -type l -regex '.*/system-.*-link' -print | tail -n 1) | "
                "fzf"
            ];
        };
    };

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/fish"
        ];
    };
}
