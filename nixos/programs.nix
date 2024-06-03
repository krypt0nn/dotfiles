{ inputs, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        vim
        micro
        wget
        curl
        git
        btop
        fastfetch
    ];

    nixpkgs.overlays = [
        (final: prev: {
            bcachefs-tools = inputs.bcachefs-tools.packages.${pkgs.system}.bcachefs-tools;
        })
    ];

    programs.zsh.enable = true;
}
