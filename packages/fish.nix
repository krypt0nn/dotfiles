{ username, pkgs, lib, ... }: {
    environment.systemPackages = with pkgs; [
        fishPlugins.tide
        fishPlugins.z
        fishPlugins.fzf-fish
    ];

    programs.fish = {
        enable = true;

        shellInit = "set fish_greeting";

        shellAliases = {
            system-update = "sudo nixos-rebuild switch --flake /system-flake";
            system-upgrade = "sudo nix flake update --flake /system-flake && sudo nixos-rebuild boot --flake /system-flake";

            system-diff = lib.concatStrings [
                "nix store diff-closures "
                "$(ls -dtr /nix/var/nix/profiles/system-*-link | tail -n 2 | head -n 1) "
                "$(ls -dtr /nix/var/nix/profiles/system-*-link | tail -n 1) | "
                "fzf"
            ];

            system-diff-running = lib.concatStrings [
                "nix store diff-closures "
                "/run/current-system "
                "$(ls -dtr /nix/var/nix/profiles/system-*-link | tail -n 1) | "
                "fzf"
            ];
        };
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".config/fish"
            ".local/share/fish"
        ];
    };
}
