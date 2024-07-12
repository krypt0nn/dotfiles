{ lib, pkgs, pkgs-unstable, ... }: {
    home = {
        username = "observer";
        homeDirectory = "/home/observer";

        packages = with pkgs; [
            vesktop
            telegram-desktop
        ];
    };

    programs = {
        git = {
            enable = true;

            userName = "Nikita Podvirnyi";
            userEmail = "krypt0nn@vk.com";

            signing = {
                signByDefault = true;
                key = "3B14311A878F6C8817482002859D416E5142AFF3";
            };

            extraConfig = {
                safe.directory = "/system-flake";
            };
        };

        zsh = {
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
                    "sudo chown -R observer /system-flake && "
                    "sudo chmod -R 755 /system-flake"
                ];

                system-forbid-edit = lib.concatStrings [
                    "sudo chown -R root /system-flake && "
                    "sudo chmod -R 755 /system-flake && "
                    "sudo chown -R observer /system-flake/.git && "
                    "sudo chmod -R 755 /system-flake/.git"
                ];

                system-update = "sudo nixos-rebuild switch --flake /system-flake";
                system-upgrade = "sudo nix flake update /system-flake && sudo nixos-rebuild boot --flake /system-flake";
            };
        };
    };

    home.persistence."/persistent/home/observer" = {
        allowOther = false;

        files = [
            ".p10k.zsh"
        ];

        directories = [
            ".config/vesktop"
            ".local/share/TelegramDesktop"
        ];
    };

    # Set keyboard languages
    dconf.settings = {
        "org/gnome/desktop/input-sources" = {
            show-all-sources = true;

            sources = with lib.hm.gvariant; [
                (mkTuple [ "xkb" "us" ])
                (mkTuple [ "xkb" "ru" ])
            ];
        };
    };
}
