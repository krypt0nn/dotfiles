{ username, pkgs-unstable, ... }: {
    networking.firewall.allowedTCPPorts = [ 9931 ];

    systemd.services.llama-server = {
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
                    --models-preset "/home/${username}/Models/models.ini" \
                    --slot-save-path "/home/${username}/Models/kv-cache" \
                    --parallel 1 \
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
