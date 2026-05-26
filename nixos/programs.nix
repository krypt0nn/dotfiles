{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        vim
        micro
        bat
        wget
        curl
        net-tools
        dnslookup
        python3
        git
        btop
        tmux
        fastfetch
        onefetch
        libqalculate
    ];

    programs.fish.enable = true;
    programs.nix-ld.enable = true;

    environment.sessionVariables.EDITOR = "micro";
}
