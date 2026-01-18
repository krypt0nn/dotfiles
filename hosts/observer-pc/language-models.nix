{ username, pkgs-unstable, ... }: {
    environment.systemPackages = with pkgs-unstable; [
        ramalama
        llama-cpp-rocm
    ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username} = {
            directories = [
                ".local/share/ramalama"
            ];
        };
    };
}
