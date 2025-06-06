{ flakeConfig, pkgs-unstable, ... }: {
    environment.systemPackages = [
        pkgs-unstable.ollama-rocm
    ];

    services.ollama = {
        enable = true;
        package = pkgs-unstable.ollama-rocm;

        environmentVariables = {
            OLLAMA_FLASH_ATTENTION = "1";
            OLLAMA_KV_CACHE_TYPE = "q8_0";
        };

        rocmOverrideGfx = "10.1.0";

        loadModels = [
            "hf.co/unsloth/Qwen2.5-Coder-7B-Instruct-128K-GGUF:Q4_K_M"
        ];
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${flakeConfig.username} = {
            directories = [
                ".ollama"
            ];
        };
    };
}
