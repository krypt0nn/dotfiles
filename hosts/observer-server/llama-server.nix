{ username, pkgs-unstable, ... }: {
    services.llama-cpp = {
        enable = true;
        package = pkgs-unstable.llama-cpp-vulkan;
        port = 9931;
        openFirewall = true;
        modelsDir = "/home/${username}/Models";
        extraFlags = [ "--embeddings" ];
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            "Models"
        ];
    };
}
