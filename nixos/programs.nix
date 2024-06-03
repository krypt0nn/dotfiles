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

    programs.zsh.enable = true;
}
