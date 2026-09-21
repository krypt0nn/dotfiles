{ username, pkgs, pkgs-unstable, inputs, ... }: let
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
                paths = [
                    pkgs-unstable.pi-coding-agent
                    pkgs.nodejs
                ];
                meta.mainProgram = "pi";
            };

            locale.enable = true;
            timeZone.enable = true;

            bubblewrap = {
                newSession = true;
                dieWithParent = true;

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

                tmpfs = [
                    "/tmp"
                ];
            };
        };
    };

    # npm package sources; pi installs them into ~/.pi/agent/npm/ at startup.
    piPackages = [
        "npm:@narumitw/pi-lsp"        # LSP
        "npm:pi-web-access"           # Web search
        "npm:pi-loop-police"          # Infinite-loop detection/breaking
        "npm:@tintinweb/pi-subagents" # Agents
    ];

    piSkillRepos = [
        {
            name = "nixos";
            url = "https://github.com/marceloeatworld/nixos-ai-skill.git";
        }
        {
            name = "rust";
            url = "https://github.com/actionbook/rust-skills.git";
        }
    ];

    settingsFile = pkgs.writeText "pi-settings-packages.json" (builtins.toJSON {
        packages = piPackages;
    });

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
        '') piSkillRepos}

        # Prune skill dirs that are no longer declared.
        keep="${keepList (map (r: r.name) piSkillRepos)}"
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
