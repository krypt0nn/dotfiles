{ username, enableImpermanence, lib, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        fishPlugins.tide
        fishPlugins.z
        fishPlugins.fzf-fish
    ];

    programs.fish = {
        enable = true;

        shellInit = "set fish_greeting";

        shellAliases = let
            # HACK
            flakePath = if enableImpermanence
                then "/system-flake"
                else "/env/nixos";
        in {
            system-update = "sudo nixos-rebuild switch --flake ${flakePath}";
            system-upgrade = "sudo nix flake update --flake ${flakePath} && sudo nixos-rebuild boot --flake ${flakePath}";

            system-diff = lib.concatStrings [
                "nix store diff-closures "
                "$(ls -dtr /nix/var/nix/profiles/system-*-link | tail -n 2 | head -n 1) "
                "$(ls -dtr /nix/var/nix/profiles/system-*-link | tail -n 1) | "
                "sed 's,\\x1b\\[[0-9;]*m,,g' | "
                "fzf"
            ];

            system-diff-running = lib.concatStrings [
                "nix store diff-closures "
                "/run/current-system "
                "$(ls -dtr /nix/var/nix/profiles/system-*-link | tail -n 1) | "
                "sed 's,\\x1b\\[[0-9;]*m,,g' | "
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
