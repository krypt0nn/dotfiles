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
            "hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:IQ3_XXS"
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
