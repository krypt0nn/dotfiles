{ username, pkgs, pkgs-unstable, ... }:
    let
        configFile = pkgs.writeText "opencode.json" (builtins.toJSON {
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

                        # Git
                        "git log *"
                        "git status *"
                        "git diff *"
                        "git show *"

                        # Cargo
                        "cargo check *"
                        "cargo build *"
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

        variantsFile = pkgs.writeText "variants.json" (builtins.toJSON {
            minimal = {
                thinkingConfig = {
                    includeThoughts = true;
                    thinkingBudget = 4 * 1024;
                };
            };

            low = {
                thinkingConfig = {
                    includeThoughts = true;
                    thinkingBudget = 8 * 1024;
                };
            };

            medium = {
                thinkingConfig = {
                    includeThoughts = true;
                    thinkingBudget = 16 * 1024;
                };
            };

            high = {
                thinkingConfig = {
                    includeThoughts = true;
                    thinkingBudget = 32 * 1024;
                };
            };

            max = {
                thinkingConfig = {
                    includeThoughts = true;
                    thinkingBudget = 64 * 1024;
                };
            };
        });
    in {
        environment.systemPackages = [ pkgs-unstable.opencode ];

        systemd.services.opencode-config = {
            after = [ "local-fs.target" "network-online.target" ];
            wants = [ "network-online.target" ];
            wantedBy = [ "multi-user.target" ];

            restartTriggers = [
                configFile
                variantsFile
            ];

            serviceConfig = {
                Type = "oneshot";
                User = "root";
                LoadCredentialEncrypted = "polzaai.key:/persistent/polzaai.key";
                RuntimeDirectory = "opencode";
                RuntimeDirectoryMode = "0750";
            };

            path = with pkgs; [
                jq
                curl
            ];

            script = ''
                set -euo pipefail

                CONFIG_DIR="/home/${username}/.config/opencode"
                CONFIG_FILE="$CONFIG_DIR/opencode.json"

                mkdir -p "$CONFIG_DIR"

                BASE_CONFIG="${configFile}"
                VARIANTS_FILE="${variantsFile}"

                API_KEY=$(cat "$CREDENTIALS_DIRECTORY/polzaai.key")

                write_fallback () {
                    jq --arg schema "https://opencode.ai/config.json" '
                        . + { "$schema": $schema }
                    ' "$BASE_CONFIG" > "$CONFIG_FILE"

                    chown ${username}:users "$CONFIG_FILE"
                    chmod 0600 "$CONFIG_FILE"
                }

                RESPONSE=$(curl -sS --fail \
                    -H "Authorization: Bearer $API_KEY" \
                    -H "Content-Type: application/json" \
                    "https://polza.ai/api/v2/models?type=chat" 2>/dev/null) || {
                    echo "polza.ai /v2/models request failed" >&2
                    write_fallback
                    exit 0
                }

                echo "$RESPONSE" | jq \
                    --arg npm "@ai-sdk/openai-compatible" \
                    --arg name "polza.ai" \
                    --arg baseURL "https://polza.ai/api/v2" \
                    --arg apiKey "$API_KEY" \
                    --slurpfile variants "$VARIANTS_FILE" \
                    --argjson maxCost 200 \
                    --argjson maxCache 30 \
                    --argjson minCtx 32000 \
                    '{
                        npm: $npm,
                        name: $name,
                        options: {
                            baseURL: $baseURL,
                            apiKey: $apiKey
                        },
                        models: (
                            [ .data[] | select(
                                ((.top_provider.pricing.completion_per_million // "9999") | tonumber) < $maxCost
                                and ((.top_provider.pricing.input_cache_read_per_million // "9999") | tonumber) < $maxCache
                                and (.top_provider.context_length // 0) >= $minCtx
                            ) | {
                                key: .id,
                                value: {
                                    name: .name,
                                    limit: {
                                        context: ((.top_provider.context_length // null) // 128000),
                                        output: ((.top_provider.max_completion_tokens // null) // 8192)
                                    },
                                    cost: {
                                        input: ((.top_provider.pricing.prompt_per_million // "0") | tonumber),
                                        output: ((.top_provider.pricing.completion_per_million // "0") | tonumber),
                                        cache_read: ((.top_provider.pricing.input_cache_read_per_million // "0") | tonumber)
                                    }
                                } + {
                                    variants: $variants[0]
                                }
                            } ] | from_entries
                        )
                    }' | jq \
                    --arg pid "polzaai" \
                    --slurpfile base "$BASE_CONFIG" \
                    '. as $prov | $base[0] | .provider[$pid] = $prov' \
                    > "$CONFIG_FILE" || {
                    echo "polza.ai model processing failed" >&2
                    write_fallback
                    exit 0
                }

                chown ${username}:users "$CONFIG_FILE"
                chmod 0600 "$CONFIG_FILE"
            '';
        };
    }
