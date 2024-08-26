{ inputs, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        vim
        micro
        wget
        curl
        git
        btop
        fastfetch
        onefetch
    ];

    programs.zsh.enable = true;
    programs.gamemode.enable = true;
}
