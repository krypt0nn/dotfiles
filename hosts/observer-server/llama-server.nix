{ username, pkgs-unstable, ... }: {
    networking.firewall.allowedTCPPorts = [ 9931 ];

    systemd.services.llama-cpp = {
        description = "llama-server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
            Type = "simple";
            User = username;
            Group = "users";
            WorkingDirectory = "/home/${username}";

            ExecStart = ''
                ${pkgs-unstable.llama-cpp-vulkan}/bin/llama-server \
                    --host 0.0.0.0 \
                    --port 9931 \
                    --models-dir "/home/${username}/Models" \
                    --parallel 1 \
                    --ctx-size 8192 \
                    --kv-unified \
                    --cache-type-k q8_0 \
                    --cache-type-v q8_0 \
                    --spec-draft-type-k q8_0 \
                    --spec-draft-type-v q8_0 \
                    --fit on \
                    --embeddings
            '';

            Restart = "always";
            RestartSec = 10;
        };
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            "Models"
        ];
    };
}
