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
            };

            locale.enable = true;
            timeZone.enable = true;

            bubblewrap = {
                newSession = true;
                dieWithParent = true;
                sockets.wayland = true;

                bind.rw = [
                    [ "/tmp/pi-agent" "/tmp" ]
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

                env.PI_CODING_AGENT_DIR = "/home/${username}/.pi/agent";

                # Bypass list for pi-web-access.
                env.NO_PROXY = "localhost,127.0.0.1,::1,.lan,.ts.net,observer-server";
            };
        };
    };

    # The very same pi binary, but without the nixpak/bubblewrap sandbox: it
    # runs with the full host filesystem and network, so it can touch paths the
    # sandbox does not bind (e.g. writing outside $HOME or running
    # `nixos-rebuild`). Escape hatch, not the default.
    pi-unsafe = pkgs.writeShellScriptBin "pi-unsafe" ''
        export PI_CODING_AGENT_DIR="''${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
        exec ${pkgs-unstable.pi-coding-agent}/bin/pi "$@"
    '';

    # npm package sources; pi installs them into ~/.pi/agent/npm/ at startup.
    settingsFile = pkgs.writeText "pi-settings-packages.json" (builtins.toJSON {
        packages = [
            "npm:pi-web-access"            # Web search
            "npm:@henryqw/pi-ask-question" # User questions
            "npm:@ravshansbox/pi-subagent" # Subagents
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
        {
            name = "humanizer";
            url = "https://github.com/blader/humanizer.git";
        }
    ];

    skillRoot = "/home/${username}/.pi/agent/skills";
    keepList = pkgs.lib.concatStringsSep " ";

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
        pi-unsafe
    ];

    # /tmp is a tmpfs, so the sandbox's scratch dir has to be recreated at boot.
    # "d" + age "-": never cleaned by systemd-tmpfiles-clean, owned by the user
    # pi runs as in the nixpak sandbox.
    systemd.tmpfiles.rules = [
        "d /tmp/pi-agent 0700 ${username} users -"
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
