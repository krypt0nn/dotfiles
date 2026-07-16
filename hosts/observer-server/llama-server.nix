{ username, lib, pkgs, pkgs-unstable, ... }:
let
    modelsConfig = pkgs.writeText "llama-models.ini" ''
        version = 1

        [*]
        sleep-idle-seconds = 180
        parallel = 1
        ctx-size = 8192
        cache-type-k = q8_0
        cache-type-v = q8_0
        spec-draft-type-k = q8_0
        spec-draft-type-v = q8_0
        fit = on
        reasoning = on
        reasoning-budget = 2048
        presence-penalty = 0.0
        repeat-penalty = 1.0

        [LFM2.5-8B-A1B-UD-IQ4_XS]
        alias = lfm2.5-8b-a1b
        temperature = 0.2
        top-k = 80
        repeat-penalty = 1.05

        [Bonsai-8B-Q1_0]
        alias = bonsai-8b
        ctx-size = 16384
        cache-type-k = q4_0
        cache-type-v = q4_0
        spec-draft-type-k = q4_0
        spec-draft-type-v = q4_0
        temperature = 0.5
        top-p = 0.9
        top-k = 20
        min-p = 0.0

        [Qwen3-1.7B-UD-Q4_K_XL]
        alias = qwen3-1.7b
        temperature = 0.6
        top-p = 0.95
        top-k = 20
        min-p = 0.0
    '';
in {
    systemd.services.llama-server = {
        description = "llama.cpp server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
            Type = "simple";

            User = username;
            Group = "users";
            SupplementaryGroups = [ "render" "video" ];

            WorkingDirectory = "/home/${username}/Models";
            EnvironmentFile = "/persistent/llama-server.secrets";

            ExecStart = lib.escapeShellArgs [
                "${pkgs-unstable.llama-cpp-vulkan}/bin/llama-server"
                "--host" "0.0.0.0"
                "--port" "9020"
                "--models-dir" "/home/${username}/Models"
                "--models-preset" "${modelsConfig}"
                "--models-max" "2"
                "--metrics"
            ];

            Restart = "on-failure";
            RestartSec = "5";
        };
    };

    networking.firewall.allowedTCPPorts = [ 9020 ];
}
