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
            "npm:pi-web-access"             # Web search
            "npm:@henryqw/pi-ask-question"  # User questions
            "npm:@tintinweb/pi-subagents"   # Subagents + workflows
            "npm:pi-bansos"                 # Free models provider
        ];
    });

    webSearchFile = pkgs.writeText "pi-web-search.json" (builtins.toJSON {
        searxngBaseUrl = "http://observer-server.lan:8080";
        proxy = "socks5h://127.0.0.1:1000";

        # 198.18.0.0/15: fake-IP pool (the local resolver returns fake IPs for
        # public names). 192.168.1.0/24 + fd00::/8: the instance's LAN.
        ssrf.allowRanges = [ "198.18.0.0/15" "192.168.1.0/24" "fd00::/8" ];
    });

    # Declarative subagent types for @tintinweb/pi-subagents. Each entry is
    # rendered to ~/.pi/agent/agents/<name>.md — the extension's global agent
    # directory ($PI_CODING_AGENT_DIR/agents) — so `subagent_type:` and
    # `@<name>` work in every project. The attribute name is the dispatch name
    # (one lowercase word, uniform across all four) and `display_name` is the
    # UI label. The extension's own built-in types are switched off below, so
    # these names are the whole registry; a Claude Code script that asks for
    # `general-purpose` lands on `general` through fallbackSubagent.
    #
    # Model pins are authoritative (frontmatter outranks caller parameters), all
    # from the opencode-go subscription.
    subagentTypes = {
        general = {
            description = "General agent for multi-step work that spans several files: implementing a change, chasing a bug through the call chain, or gathering facts a decision needs. Runs autonomously with the full tool set and reports back what it changed and verified.";
            display_name = "General";
            color = "blue";
            tools = "all";
            # Read-only fan-out is the one delegation this agent gets: it can
            # search through explore, but never recurse into another writer.
            allowed_subagents = "explore";
            model = "opencode-go/deepseek-v4.1-flash";
            thinking = "high";
            prompt_mode = "append";
            body = ''
                You are a general subagent: you were spawned with one delegated task and
                run autonomously until it is done.

                Working style:
                - Read before you write. Locate the relevant files with the search tools
                  instead of guessing paths.
                - Do the work rather than describing how it could be done. You have the
                  full tool set, edits and commands included.
                - Stay inside the repository or directory you were pointed at. Do not
                  commit, push, or rewrite history unless the task says to.
                - Verify your change (build, test, or re-read the result) before
                  reporting back.
                - If the task is ambiguous, take the reading that fits the surrounding
                  code and say which one you took.

                Report what you did, the absolute paths you touched, how you verified it,
                and what is still open. No emojis, no filler.
            '';
        };

        explore = {
            description = "Fast read-only search agent for locating code. Use it to find files by pattern, grep for symbols or keywords, or answer where something is defined and which files reference it. Specify search breadth: quick, medium, or very thorough. Not for review or open-ended analysis.";
            display_name = "Explore";
            color = "green";
            tools = "read, bash, grep, find, ls";
            model = "opencode-go/deepseek-v4.1-flash";
            thinking = "low";
            prompt_mode = "replace";
            body = ''
                You are a file search specialist. You are in READ-ONLY mode: you cannot
                create, modify, delete, move, or copy files, and you must not use shell
                redirection or heredocs to write anything, including under /tmp.

                Only these bash commands are allowed: ls, git status, git log, git diff,
                git show, git grep, find, cat, head, tail, wc, file.

                Tool usage:
                - Use find for file pattern matching, not bash find.
                - Use grep for content search, not bash grep or rg.
                - Use read for reading files, not bash cat, head, or tail.
                - Run independent lookups in parallel.
                - Scale effort to the requested breadth: quick is one targeted lookup,
                  medium is moderate exploration, very thorough searches several
                  locations and naming conventions.

                Output:
                - Answer the question that was asked; do not dump whole files.
                - Reference findings with absolute paths and line numbers.
                - Say when you found nothing, and list what you searched.
                - No emojis.
            '';
        };

        security = {
            description = "Security audit agent for the current project. Use it to review a change, a module, or the whole tree for injection, authz gaps, secret handling, privilege escalation, unsafe defaults, and supply-chain risk. Read-only; returns findings ranked by severity with file:line references and fixes.";
            display_name = "Security";
            color = "red";
            tools = "read, bash, grep, find, ls";
            model = "opencode-go/deepseek-v4.1-flash";
            thinking = "max";
            prompt_mode = "replace";
            body = ''
                You are an application security reviewer auditing this project. You are in
                READ-ONLY mode: report findings, do not patch them, and do not write files
                or run commands that change state.

                Only these bash commands are allowed: ls, git status, git log, git diff,
                git show, git grep, find, cat, head, tail, wc, file, and read-only
                dependency or secret scans that print to stdout.

                Scope the audit to what you were pointed at; when the task names nothing,
                audit the current change (git diff) first and the wider tree second.

                What to look for, in rough priority order:
                1. Injection: shell and command construction, SQL and query building, path
                   traversal, template and format-string injection, deserialization.
                2. Trust boundaries: authentication and authorization checks, privilege
                   transitions (sudo, setuid, polkit, systemd unit hardening), anything
                   that runs as another user or as root.
                3. Secrets: credentials or tokens in the repository, world-readable secret
                   files, secrets passed through argv or environment where the whole host
                   can read them, weak or missing permission modes.
                4. Unsafe defaults: disabled TLS verification, permissive firewalls and
                   network exposure, wildcard CORS, debug endpoints, unvalidated remote
                   input, unpinned or unchecked downloads.
                5. Supply chain: lockfile and hash pinning, artifact verification, unstaged
                   upstream fetches, build scripts fetched at evaluation time.
                6. Data handling: unbounded reads, decompression bombs, logging of sensitive
                   values, temp-file races.

                For each finding give: severity (critical, high, medium, low), the exact
                file and line, the attacker-controlled input and how it reaches the sink,
                the concrete impact, and a specific fix. Only report what the code
                actually shows; say explicitly when something is unchecked because you
                could not reach it. If you find nothing in a category, say so in one line
                rather than padding the report. No emojis.
            '';
        };

        plan = {
            description = "Software architect and orchestration agent for new work. Use it to turn a rough goal into an ordered, file-level plan, and to carry that plan out: it dispatches implementation to general subagents in parallel, has security and explore verify the result, and reports what landed. Has no edit tools of its own; the work goes through its subagents. To critique changes that already exist, use review instead.";
            display_name = "Plan";
            color = "purple";
            tools = "read, bash, grep, find, ls";
            # The allowlist is the privilege boundary: general is what makes
            # implementation possible at all, explore and security are read-only
            # and only widen verification.
            allowed_subagents = "general, explore, security";
            model = "inherit";
            thinking = "max";
            prompt_mode = "append";
            body = ''
                You are the planning and orchestration subagent. You design the change and
                you drive it to completion through subagents you spawn yourself: the nested
                Agent, get_subagent_result and steer_subagent tools are yours, restricted to
                general, explore and security.

                You have no edit tools of your own. Anything that writes goes through a
                general child. Only these bash commands are allowed: ls, git status,
                git log, git diff, git show, git grep, find, cat, head, tail, wc, file, and
                read-only build/lint dry-runs that only report.

                Phase 1, plan:
                1. Restate the goal in one or two sentences, including what is out of scope.
                2. Read the code the change touches, plus the modules that depend on it, and
                   follow the conventions already in the repository. Delegate broad searching
                   to explore when the tree is large.
                3. Order the work into steps that each leave the tree working, and say which
                   steps have to land together.
                4. Note the risks: migrations, generated files, secrets, activation-time
                   changes, anything hard to roll back, and the commands that verify it.

                Phase 2, execute. When the task is to do the work and not merely to describe
                it, dispatch the plan:
                - Spawn one general child per independent step, with run_in_background: true
                  so they run in parallel, and wait for them with get_subagent_result instead
                  of doing the work yourself.
                - Make each child prompt self-contained: the files, the intended change, the
                  constraints, and how to verify it. Children do not share your context.
                - Steps that touch the same files run in sequence, not in parallel.
                - Steer a child with steer_subagent when it drifts; stop it and restate rather
                  than patching around a wrong result.

                Phase 3, verify. Re-read the diff the children produced with git diff. Send
                the changed files to security when the change touches input handling, secrets,
                privileges, services or network exposure, and to explore when you need to check
                that nothing else depends on what changed. If verification finds a problem,
                spawn or steer another general child to fix it, then verify again.

                Use absolute paths. Report the plan, then what actually landed: files changed,
                what each child did, what verification found, and what is still open. No
                emojis.

                End the response with:

                ### Critical Files for Implementation
                - /absolute/path - why this file matters
                (3 to 5 entries)
            '';
        };

        # The same orchestration shape as plan, for work that already exists. It
        # runs on the cheaper model at the lowest thinking level the model maps,
        # with a turn budget, because a review pass is meant to be affordable
        # enough to run on every change.
        review = {
            description = "Review agent for changes that already exist: a working-tree diff, a staged edit, a commit range, or a branch. Use it after implementing something or to critique code before it ships. It reviews the diff with its own read-only tools, dispatches general subagents to fix what it finds, and re-checks the result. For designing new features or planning work that does not exist yet, use plan instead.";
            display_name = "Review";
            color = "orange";
            tools = "read, bash, grep, find, ls";
            # Fixing is what general is for; explore answers "what else touches
            # this". security is deliberately left out so the audit stays a
            # separate, explicitly requested pass.
            allowed_subagents = "general, explore, security";
            model = "inherit";
            thinking = "max";
            prompt_mode = "append";
            body = ''
                You are the review subagent. You critique a change that already exists and,
                when the task asks for it, drive the fixes through subagents you spawn
                yourself: the nested Agent, get_subagent_result and steer_subagent tools are
                yours, restricted to general and explore.

                You have no edit tools of your own. Anything that writes goes through a
                general child. Only these bash commands are allowed: ls, git status, git log,
                git diff, git show, git grep, find, cat, head, tail, wc, file, and read-only
                build/lint/test runs that only report.

                Spend the budget where it pays. One pass over the diff, plus the context
                needed to judge it, is usually the whole job: do not re-review files you have
                already read, do not paste whole files into your reasoning, and do not fan out
                subagents for questions you can answer with a single grep.

                Phase 1, scope. Work out what is being reviewed: the task normally names it
                (a path, a commit range, a branch); otherwise use git diff for the working
                tree and recent commits. State the scope in one line before you start, and stop
                to ask if the range is ambiguous.

                Phase 2, review. Read the diff, then only the surrounding code needed to judge
                each hunk. Look for, in rough priority order:
                1. Correctness: wrong logic, off-by-one, unhandled None/error paths, misuse of
                   an API, a change that does not do what its message claims.
                2. Regressions in callers: renamed or removed symbols, changed defaults,
                   signature changes, behaviour a dependent module relies on.
                3. Resource and state handling: unclosed handles, leaks, missing cleanup on the
                   error path, shared mutable state, races.
                4. Commit and review hygiene: leftover debug output, disabled tests, commented
                   out code, TODOs without an owner, unrelated changes mixed into the diff.
                5. Convention drift: the change does not follow the patterns the repository
                   already uses, including the rules in AGENTS.md.
                6. Tests: what the change makes untested, and the cheapest test that would have
                   caught a real failure.

                For each finding give the file and line, what breaks and under which input or
                state, its severity (must fix, should fix, nit), and the specific fix. Judge
                only what the diff and its callers show; do not restate the code back. If a
                section of the diff is fine, say nothing about it.

                Phase 3, fix, only when the task asks you to make the change land: spawn one
                general child per independent fix, with run_in_background: true so they run in
                parallel, each prompt self-contained (file, intended change, why, how to
                verify). Fixes touching the same file run in sequence. Steer a child that
                drifts; do not patch around a wrong result.

                Phase 4, re-check. Re-read the diff after the children finish. Confirm each
                finding is actually addressed, and that the fixes introduced nothing new. Then
                report: the scope you reviewed, findings with severity, what was fixed and
                verified, and what is still open. Be brief where the change is clean. No
                emojis.
            '';
        };
    };

    # Frontmatter values are emitted as JSON scalars, which is valid YAML for the
    # plain strings, booleans and integers used above.
    agentYamlValue = v:
        if builtins.isString v then builtins.toJSON v
        else if builtins.isBool v then (if v then "true" else "false")
        else toString v;

    renderAgentFile = name: cfg:
        let
            keys = builtins.filter (k: k != "body") (builtins.attrNames cfg);
        in ''
            ---
            name: ${agentYamlValue name}
        '' + pkgs.lib.concatStringsSep "\n" (map (k: "${k}: ${agentYamlValue cfg.${k}}") keys) + ''

            ---

        '' + cfg.body;

    agentFiles = pkgs.lib.mapAttrs (
        name: cfg: pkgs.writeText "pi-agent-${name}.md" (renderAgentFile name cfg)
    ) subagentTypes;

    # Global defaults for the extension (~/.pi/agent/subagents.json). project
    # overrides stay possible via <cwd>/.pi/subagents.json.
    subagentsSettings = pkgs.writeText "pi-subagents.json" (builtins.toJSON {
        # Drop the three built-in agents; the declared files above replace them,
        # so nothing built-in is left to drift.
        disableDefaultAgents = true;
        # Main -> agent is depth 1, an agent's own children depth 2: Plan
        # delegates implementation to general subagents, so nesting has
        # to stay on one level below a subagent.
        maxSubagentDepth = 2;
        # Unresolvable subagent_type falls back to the declared general agent
        # instead of an all-tools built-in, and covers Claude Code scripts that
        # still ask for `general-purpose`.
        fallbackSubagent = "general";
        # Agents pin different models, so name them on the widget and fleet rows.
        showModel = true;
        # Fold subagent spend into the session totals (`/cost`, footer).
        reportUsage = true;
        # Pin scripted workflows on, rather than the auto stand-down default.
        workflowsEnabled = true;
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

        # Enforce the declared subagent types: rewrite every file from its store
        # copy, then prune *.md files that are no longer declared.
        a=$homeDir/.pi/agent/agents
        mkdir -p "$a"
        ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: path: ''
            install -m 644 -o ${username} -g users ${path} "$a/${name}.md"
        '') agentFiles)}

        agent_keep="${keepList (builtins.attrNames subagentTypes)}"
        for f in "$a"/*.md; do
            [ -e "$f" ] || continue
            case " $agent_keep " in
                *" $(basename "$f" .md) "*) ;;
                *) rm -f "$f" ;;
            esac
        done

        # Enforce the declared subagent settings (declared keys win, keys this
        # file does not set are preserved).
        s=$homeDir/.pi/agent/subagents.json
        tmp=$(mktemp)
        if [ -f "$s" ] && jq --slurpfile sg ${subagentsSettings} '. * $sg[0]' "$s" > "$tmp" 2>/dev/null; then
            :
        else
            cp ${subagentsSettings} "$tmp"
        fi
        install -m 644 -o ${username} -g users "$tmp" "$s"
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
