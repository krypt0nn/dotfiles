{ pkgs, lib, username, ... }: {
    environment.systemPackages = with pkgs; [
        fishPlugins.tide
        fishPlugins.z
        fishPlugins.fzf-fish
    ];

    programs.fish = {
        enable = true;

        shellInit = "set fish_greeting";

        shellAliases = {
            system-allow-edit = lib.concatStrings [
                "sudo chown -R ${username} /system-flake && "
                "sudo chmod -R 755 /system-flake"
            ];

            system-forbid-edit = lib.concatStrings [
                "sudo chown -R root /system-flake && "
                "sudo chmod -R 755 /system-flake && "
                "sudo chown -R ${username} /system-flake/.git && "
                "sudo chmod -R 755 /system-flake/.git"
            ];

            system-update = "sudo nixos-rebuild switch --flake /system-flake";
            system-upgrade = "sudo nix flake update --flake /system-flake && sudo nixos-rebuild boot --flake /system-flake";

            system-diff = lib.concatStrings [
                "nix store diff-closures "
                "$(ls -tr /nix/var/nix/profiles/system-*-link | tail -n 2 | head -n 1) "
                "$(ls -tr /nix/var/nix/profiles/system-*-link | tail -n 1) | "
                "fzf"
            ];

            system-diff-running = lib.concatStrings [
                "nix store diff-closures "
                "/run/current-system "
                "$(ls -tr /nix/var/nix/profiles/system-*-link | tail -n 1) | "
                "fzf"
            ];
        };
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
            directories = [
                ".config/fish"
                ".local/share/fish"
            ];
        };
    };
}
