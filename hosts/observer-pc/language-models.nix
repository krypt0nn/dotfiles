{ username, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
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
