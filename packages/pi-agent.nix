{ username, pkgs, pkgs-unstable, inputs, ... }:
let
    mkNixPak = inputs.nixpak.lib.nixpak {
        inherit (pkgs) lib;
        inherit pkgs;
    };

    pi-wrapped = mkNixPak {
        config = { sloth, ... }: {
            imports = with inputs.nixpak.nixpakModules; [
                network
            ];

            # npm package sources (piPackages) are installed by pi itself at
            # runtime via the `npm` CLI, so node/npm must be on PATH inside the
            # sandbox.
            app.package = pkgs.symlinkJoin {
                name = "pi-coding-agent-wrapped";
                meta.mainProgram = "pi";

                paths = with pkgs; [
                    pkgs-unstable.pi-coding-agent
                    nodejs
                    wl-clipboard
                ];

                # bin/pi becomes a launcher that applies the declarative
                # optchat role defaults to the installed pi-optchat before the
                # real agent starts, so profiles created this session get them.
                postBuild = ''
                    mv $out/bin/pi $out/bin/.pi-real
                    cat > $out/bin/pi <<WRAP
                    #!${pkgs.runtimeShell}
                    exec ${patchDefaults} "$out/bin/.pi-real" "\$@"
                    WRAP
                    chmod +x $out/bin/pi
                '';
            };

            locale.enable = true;
            timeZone.enable = true;

            bubblewrap = {
                newSession = true;
                dieWithParent = true;
                sockets.wayland = true;

                bind.rw = [
                    (sloth.envOr "PWD" sloth.homeDir)
                    (sloth.concat' sloth.homeDir "/.pi/agent")
                    (sloth.concat' sloth.homeDir "/.npm")
                    (sloth.concat' sloth.homeDir "/.cargo")
                ];

                bind.ro = [
                    "/run/current-system/sw"
                    [ "/run/current-system/sw/bin" "/usr/bin" ]
                    [ "/run/current-system/sw/bin" "/bin" ]
                    "/run/wrappers"
                    "/run/nix"
                    "/nix/store"
                ];

                tmpfs = [ "/tmp" ];

                env.PI_CODING_AGENT_DIR = "/home/${username}/.pi/agent";
                env.OPTCHAT_HOME = "/home/${username}/.pi/agent/optchat";

                # Bypass list for pi-web-access.
                env.NO_PROXY = "localhost,127.0.0.1,::1,.lan,.ts.net,observer-server";
            };
        };
    };

    # npm package sources; pi installs them into ~/.pi/agent/npm/ at startup.
    settingsFile = pkgs.writeText "pi-settings-packages.json" (builtins.toJSON {
        packages = [
            "npm:@narumitw/pi-lsp"         # LSP
            "npm:pi-web-access"            # Web search
            "npm:@henryqw/pi-ask-question" # Ask user questions
            # "npm:pi-optchat"             # Context compression and subagents
            "npm:pi-loop-police"           # Detect and break thinking loops
            "npm:pi-bansos"                # Free models provider
        ];
    });

    webSearchFile = pkgs.writeText "pi-web-search.json" (builtins.toJSON {
        searxngBaseUrl = "http://observer-server.lan:8080";
        proxy = "socks5h://127.0.0.1:1000";

        # 198.18.0.0/15: fake-IP pool (the local resolver returns fake IPs for
        # public names). 192.168.1.0/24 + fd00::/8: the instance's LAN.
        ssrf.allowRanges = [ "198.18.0.0/15" "192.168.1.0/24" "fd00::/8" ];
    });

    skillRepos = [
        {
            name = "nixos";
            url = "https://github.com/marceloeatworld/nixos-ai-skill.git";
        }
        {
            name = "rust";
            url = "https://github.com/actionbook/rust-skills.git";
        }
    ];

    optchatRolesFile = pkgs.writeText "pi-optchat-roles.json" (builtins.toJSON {
        compactor = {
            provider = "openrouter";
            model = "inclusionai/ling-3.0-flash";
            thinking = "medium";
        };
        subagent = {
            provider = "openrouter";
            model = "~deepseek/deepseek-flash-latest";
            thinking = "high";
        };
    });

    skillRoot = "/home/${username}/.pi/agent/skills";
    keepList = pkgs.lib.concatStringsSep " ";

    # pi-optchat hardcodes its new-profile defaults (anthropic claude models) in
    # src/profiles.ts and offers no override, so this script rewrites them to
    # the declared roles on every pi launch (npm reinstalls revert it, so it
    # must be re-applied at launch, not just at system activation).
    patchDefaults = pkgs.writeShellScript "pi-optchat-patch-defaults" ''
        export PATH=${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:${pkgs.jq}/bin:$PATH
        real=$1; shift
        f="$HOME/.pi/agent/npm/node_modules/pi-optchat/src/profiles.ts"
        if [ -f "$f" ]; then
            c=$(jq -c .compactor ${optchatRolesFile})
            s=$(jq -c .subagent ${optchatRolesFile})
            if ! grep -qF "compactor: $c" "$f"; then
                sed -i -E \
                    -e "s|compactor: [{] provider: '[^']*', model: '[^']*', thinking: '[^']*' [}]|compactor: $c|" \
                    -e "s|subagent: [{] provider: '[^']*', model: '[^']*', thinking: '[^']*' [}]|subagent: $s|" \
                    "$f" || echo "pi-optchat: failed to patch profile default models" >&2
                grep -qF "compactor: $c" "$f" \
                    || echo "pi-optchat: default models NOT patched (upstream defaults format changed?)" >&2
            fi
        fi
        exec "$real" "$@"
    '';

    # Oneshot script that makes ~/.pi/agent/skills mirror `piSkillRepos`:
    # declared repos are cloned/updated, anything not declared is deleted.
    syncScript = pkgs.writeShellScript "pi-skills-sync" ''
        skillRoot=${skillRoot}
        mkdir -p "$skillRoot"

        ${pkgs.lib.concatMapStringsSep "\n" (r: ''
            dest=$skillRoot/${r.name}
            if [ -d "$dest/.git" ]; then
                ${pkgs.git}/bin/git -C "$dest" pull --ff-only >/dev/null 2>&1 || echo "pi-skills: failed to update ${r.name}"
            else
                rm -rf "$dest"
                ${pkgs.git}/bin/git clone --depth 1 ${r.url} "$dest" >/dev/null 2>&1 \
                    || echo "pi-skills: failed to clone ${r.name}"
            fi
        '') skillRepos}

        # Prune skill dirs that are no longer declared.
        keep="${keepList (map (r: r.name) skillRepos)}"
        for d in "$skillRoot"/*; do
            [ -d "$d" ] || continue
            case " $keep " in
                *" $(basename "$d") "*) ;;
                *) rm -rf "$d" ;;
            esac
        done
    '';

    # Activation script that enforces declarative state for plugins: the
    # settings.json "packages" list is set EXACTLY to `piPackages` (user
    # additions are removed — declarative, not additive).
    piAgentSync = pkgs.writeShellScript "pi-agent-sync" ''
        export PATH=${pkgs.coreutils}/bin:${pkgs.jq}/bin:$PATH

        homeDir=/home/${username}
        f=$homeDir/.pi/agent/settings.json

        # Enforce the packages list (preserving all other settings).
        mkdir -p "$(dirname "$f")"
        if [ -f "$f" ]; then
            tmp=$(mktemp)
            jq --slurpfile st ${settingsFile} '.packages = $st[0].packages' "$f" > "$tmp" \
                && cat "$tmp" > "$f"
            rm -f "$tmp"
        else
            cp ${settingsFile} "$f"
        fi

        # Enforce the declared pi-web-access settings (recursive merge, so
        # runtime-added API keys survive). This script runs as root, so the file
        # has to be handed over explicitly: a root-owned 0600 file is unreadable
        # for the user pi actually runs as inside the nixpak sandbox.
        w=$homeDir/.pi/agent/web-search.json
        mkdir -p "$homeDir/.pi/agent"
        tmp=$(mktemp)
        if [ -f "$w" ] && jq --slurpfile ws ${webSearchFile} '. * $ws[0]' "$w" > "$tmp" 2>/dev/null; then
            :
        else
            cp ${webSearchFile} "$tmp"
        fi
        install -m 600 -o ${username} -g users "$tmp" "$w"
        rm -f "$tmp"
    '';
in {
    environment.systemPackages = [
        pi-wrapped.config.env
    ];

    # One-shot service that clones/updates the skill repos into the user's
    # global skill directory on every boot, and prunes undeclared ones.
    systemd.services.pi-skills-sync = {
        description = "Mirror pi agent skill repositories";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            User = username;
            ExecStart = syncScript;
            RemainAfterExit = true;
        };
    };

    system.activationScripts.piAgentPackages = ''
        ${piAgentSync}
    '';
}
