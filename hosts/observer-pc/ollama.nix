{ username, pkgs-unstable, ... }: {
    environment.systemPackages = with pkgs-unstable; [
        ollama-rocm
        ramalama
    ];

    services.ollama = {
        enable = true;
        package = pkgs-unstable.ollama-rocm;

        environmentVariables = {
            OLLAMA_CONTEXT_LENGTH = "8192";
        };

        rocmOverrideGfx = "10.1.0";

        loadModels = [
            "hf.co/unsloth/Qwen2.5-Coder-7B-Instruct-128K-GGUF:Q4_K_M"
        ];
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username} = {
            directories = [
                ".ollama"
                ".local/share/ramalama"
            ];
        };
    };
}
