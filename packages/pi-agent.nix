{
    username,
    pkgs,
    pkgs-unstable,
    ...
}: let
    # Pi packages to install. Add new entries here. Git sources without a ref
    # track the default branch; `pi update --extensions` (or `pi update --all`)
    # reconciles the clones to the latest HEAD.
    piPackages = [
        "git:github.com/nicobailon/pi-subagents" # subagent orchestration
        "git:github.com/nicobailon/pi-web-access" # web search + fetch tools
        "git:github.com/apmantza/pi-lens" # real-time code feedback: LSP, linters, formatters
        "git:github.com/tmonk/pi-goal-x" # /goal: persistent goal planning + completion auditor
    ];

    # Skill repos cloned into ~/.pi/agent/skills/<name>/ (auto-discovered by pi:
    # any directory containing SKILL.md is found recursively). Kept up to date
    # by the pi-skills-sync systemd service below — add new repos to this list.
    piSkillRepos = [
        {
            name = "nixos"; # https://github.com/marceloeatworld/nixos-ai-skill
            url = "https://github.com/marceloeatworld/nixos-ai-skill.git";
        }
        {
            name = "rust"; # https://github.com/actionbook/rust-skills (skills/ subdirs are discovered)
            url = "https://github.com/actionbook/rust-skills.git";
        }
    ];

    settingsFile = pkgs.writeText "pi-settings-merge.json" (builtins.toJSON { packages = piPackages; });

    # Idempotent activation: merge `piPackages` into the user's
    # ~/.pi/agent/settings.json "packages" list, deduplicating by source
    # (string entries match as-is, object entries match by .source), while
    # preserving all other user-managed settings and any user-installed
    # packages.
    jqMerge = pkgs.writeText "pi-packages-merge.jq" ''
        def src: if type == "object" then .source else . end;
        .[0] as $cur
        | .[1] as $new
        | $cur
        | .packages = (
              (.packages // [])
              + ($new.packages | map(select(
                    (. | src) as $s
                    | [($cur.packages // [])[] | src]
                    | index($s) | not
                )))
          )
    '';

    skillRoot = "/home/${username}/.pi/agent/skills";

    syncScript = pkgs.writeShellScript "pi-skills-sync" ''
        ${pkgs.lib.concatMapStringsSep "\n" (r: ''
            dest=${skillRoot}/${r.name}
            if [ -d "$dest/.git" ]; then
                ${pkgs.git}/bin/git -C "$dest" pull --ff-only >/dev/null 2>&1 || echo "pi-skills: failed to update ${r.name}"
            else
                rm -rf "$dest"
                ${pkgs.git}/bin/git clone --depth 1 ${r.url} "$dest" >/dev/null 2>&1 \
                    || echo "pi-skills: failed to clone ${r.name}"
            fi
        '') piSkillRepos}
    '';
in {
    environment.systemPackages = [ pkgs-unstable.pi-coding-agent ];

    # One-shot service that clones/updates the skill repos into the user's
    # global skill directory on every boot.
    systemd.services.pi-skills-sync = {
        description = "Clone/update pi agent skill repositories";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            User = username;
            ExecStart = syncScript;
            RemainAfterExit = true;
        };
    };

    system.activationScripts.piAgentPackages = ''
        export PATH=${pkgs.coreutils}/bin:${pkgs.diffutils}/bin:$PATH
        f=/home/${username}/.pi/agent/settings.json
        if [ -f "$f" ]; then
            tmp=$(mktemp)
            ${pkgs.jq}/bin/jq -s -f ${jqMerge} "$f" ${settingsFile} > "$tmp" \
                && if ! cmp -s "$tmp" "$f"; then
                    cat "$tmp" > "$f";
                fi
            rm -f "$tmp"
        fi
    '';
}
