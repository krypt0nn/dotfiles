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

            app.package = pkgs-unstable.pi-coding-agent;

            locale.enable = true;
            timeZone.enable = true;

            bubblewrap = {
                newSession = true;
                dieWithParent = true;

                bind.rw = [
                    (sloth.envOr "PWD" sloth.homeDir)
                    (sloth.concat' sloth.homeDir "/.pi/agent")
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

    # NOTE: entries must be plain "git:<host>/<owner>/<repo>" sources;
    # pi clones them into ~/.pi/agent/git/<host>/<owner>/<repo>.
    piPackages = [
        "git:github.com/apmantza/pi-lens"         # LSP
        "git:github.com/nicobailon/pi-web-access" # Web search
        "git:github.com/tintinweb/pi-subagents"   # Agents
    ];

    # Relative clone paths (strip the "git:" scheme) used to prune
    # undeclared clones from ~/.pi/agent/git.
    piPackagePaths = map (p: pkgs.lib.removePrefix "git:" p) piPackages;

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

    # Activation: enforce declarative state for plugins.
    #  1. settings.json "packages" is set EXACTLY to `piPackages`
    #     (user additions are removed — declarative, not additive).
    #  2. Git clones under ~/.pi/agent/git that no longer correspond to a
    #     declared package are deleted.
    piAgentSync = pkgs.writeShellScript "pi-agent-sync" ''
        export PATH=${pkgs.coreutils}/bin:${pkgs.jq}/bin:$PATH

        homeDir=/home/${username}
        f=$homeDir/.pi/agent/settings.json
        g=$homeDir/.pi/agent/git

        # 1. Enforce the packages list (preserving all other settings).
        mkdir -p "$(dirname "$f")"
        if [ -f "$f" ]; then
            tmp=$(mktemp)
            jq --slurpfile st ${settingsFile} '.packages = $st[0].packages' "$f" > "$tmp" \
                && cat "$tmp" > "$f"
            rm -f "$tmp"
        else
            cp ${settingsFile} "$f"
        fi

        # 2. Delete clones of packages that are no longer declared.
        keep="${keepList piPackagePaths}"
        for d in "$g"/*/*/*; do
            [ -d "$d" ] || continue
            rel=''${d#"$g"/}
            case " $keep " in
                *" $rel "*) ;;
                *) rm -rf "$d" ;;
            esac
        done

        # Remove now-empty host/owner directories (deepest first).
        find "$g" -mindepth 1 -depth -type d -empty -delete 2>/dev/null || true
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
