{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        vim
        micro
        bat
        wget
        curl
        git
        btop
        fastfetch
        onefetch
        cachix
        libqalculate
    ];

    programs.zsh.enable = true;
    programs.gamemode.enable = true;

    environment.sessionVariables.EDITOR = "micro";
}
