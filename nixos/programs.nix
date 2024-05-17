{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        vim
        micro
        wget
        curl
        git
        btop
        fastfetch
    ];
}
