{ username, pkgs-unstable, ... }:
    let
        config = builtins.toJSON {
            "$schema" = "https://opencode.ai/config.json";

            lsp = true;

            permission = {
                edit = "ask";
                bash = {
                    "*" = "ask";
                } // (builtins.listToAttrs (
                    map (cmd: {
                        name = cmd;
                        value = "allow";
                    }) [
                        # Filesystem
                        "ls *"
                        "find *"
                        "stat *"
                        "file *"
                        "df *"
                        "du *"
                        "lsblk *"
                        "pwd *"
                        "realpath *"
                        "basename *"
                        "dirname *"

                        # Text and files content
                        "cat *"
                        "grep *"
                        "head *"
                        "tail *"
                        "sort *"
                        "cut *"
                        "wc *"
                        "jq *"
                        "hexdump *"
                        "printf *"
                        "echo *"
                        "diff *"

                        # Files checksumming
                        "sha256sum *"
                        "sha512sum *"
                        "md5sum *"

                        # Git
                        "git log *"
                        "git status *"
                        "git diff *"
                        "git show *"
                    ]
                ));
            };

            provider.llama-cpp = {
                npm = "@ai-sdk/openai-compatible";
                name = "llama.cpp";
                options = {
                    baseURL = "http://127.0.0.1:9020";
                    apiKey = "";
                };
                models.default = {
                    name = "default";
                    context = 30000;
                    output = 8192;
                };
            };
        };
    in {
        environment.systemPackages = [ pkgs-unstable.opencode ];

        systemd.tmpfiles.rules = [
            "d /home/${username}/.config/opencode 0755 ${username} users -"
            "F /home/${username}/.config/opencode/opencode.json 0644 ${username} users - ${config}"
        ];

        environment.persistence."/persistent" = {
            hideMounts = true;

            users.${username}.directories = [
                ".config/opencode"
                ".local/share/opencode"
            ];
        };
    }
