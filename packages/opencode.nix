{ username, pkgs, pkgs-unstable, ... }:
let
    nixosSkill = fetchGit {
        url = "https://github.com/marceloeatworld/nixos-ai-skill";
        rev = "807265c89509ca9f4170f35c32ee916a52901922";
    };

    rustSkills = fetchGit {
        url = "https://github.com/actionbook/rust-skills";
        rev = "fa60f7931223646fb71c4586b4a6c8545016076a";
    };

    gtkSkill = fetchGit {
        url = "https://github.com/gotar/opencode-config";
        rev = "aa541e7066fcea4d054540410ddbeb44e165556b";
    };

    ponytail = fetchGit {
        url = "https://github.com/DietrichGebert/ponytail";
        rev = "40e50d9e03242aa5dd53ac771950f9127362b25f";
    };

    config = pkgs.writeText "opencode.json" (builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";

        lsp = true;

        plugin = [
            "${ponytail}/.opencode/plugins/ponytail.mjs"
        ];

        skills = {
            paths = [
                "${nixosSkill}"
                "${rustSkills}/skills"
                "${gtkSkill}/skills/gtk-ui-ux-engineer"
                "${ponytail}/skills"
            ];
        };

        permission = {
            external_directory = {
                "/nix/store/**" = "allow";
                "$HOME/.cargo/git/checkouts/**" = "allow";
                "/persistent/**" = "deny";
                "$HOME/.ssh/**" = "deny";
                "$HOME/.gnupg/**" = "deny";
                "*" = "ask";
            };

            edit = {
                "*.md" = "allow";
                "*" = "ask";
            };

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
                    "rg *"
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
                    "b3sum *"

                    # Processes
                    "ps *"

                    # Network
                    "ping *"
                    "curl *"
                    "wget *"
                    "nc *"

                    # Git
                    "git log *"
                    "git status *"
                    "git diff *"
                    "git show *"
                    "git ls-tree *"
                    "git ls-remote *"

                    # Nix
                    "nix flake check *"

                    # Cargo
                    "cargo tree *"
                    "cargo check *"
                    "cargo clippy *"
                    "cargo build *"
                    "cargo test *"
                ]
            ));
        };

        model = "deepseek/deepseek-v4-flash";

        provider = {
            llama-cpp = {
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
    });
in {
    environment.systemPackages = [ pkgs-unstable.opencode ];

    systemd.tmpfiles.rules = [
        "d /home/${username}/.config/opencode 0755 ${username} users -"
        "F /home/${username}/.config/opencode/opencode.json 0644 ${username} users - ${config}"
    ];
}
