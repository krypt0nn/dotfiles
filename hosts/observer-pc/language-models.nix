{ pkgs-unstable, ... }: {
    environment.systemPackages = with pkgs-unstable; [ llama-cpp-vulkan ];
}
