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
        b3sum
    ];

    programs.nix-ld.enable = true;

    environment.variables.EDITOR = "micro";
}
