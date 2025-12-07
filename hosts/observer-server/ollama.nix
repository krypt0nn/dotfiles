{ username, pkgs-unstable, ... }: {
    environment.systemPackages = with pkgs-unstable; [
        ollama
    ];

    services.ollama = {
        enable = true;
        package = pkgs-unstable.ollama;

        environmentVariables = {
            OLLAMA_KV_CACHE_TYPE = "q8_0";
            OLLAMA_CONTEXT_LENGTH = "8192";
        };
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username} = {
            directories = [
                ".ollama"
            ];
        };
    };
}
