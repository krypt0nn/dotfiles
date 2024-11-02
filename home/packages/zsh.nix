{ flakeConfig, lib, pkgs, ... }: {
    programs.zsh = {
        enable = true;

        syntaxHighlighting.enable = true;
        historySubstringSearch.enable = true;
        autosuggestion.enable = true;

        plugins = [
            {
                name = "zsh-powerlevel10k";
                src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
                file = "powerlevel10k.zsh-theme";
            }
        ];

        oh-my-zsh = {
            enable = true;

            plugins = [
                "git"
                "sudo"
            ];
        };

        initExtra = "source ~/.p10k.zsh";

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
                "less"
            ];

            system-diff-running = lib.concatStrings [
                "nix store diff-closures "
                "/run/current-system "
                "$(find /nix/var/nix/profiles -type l -regex '.*/system-.*-link' -print | tail -n 1) | "
                "less"
            ];
        };
    };

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        files = [
            ".p10k.zsh"
        ];
    };
}
