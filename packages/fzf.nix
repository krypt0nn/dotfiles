{ pkgs, ... }: {
    environment.systemPackages = [ pkgs.fzf ];

    programs.fzf = {
        keybindings = true;
        fuzzyCompletion = true;
    };
}
