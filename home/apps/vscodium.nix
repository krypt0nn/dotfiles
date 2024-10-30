{ flakeConfig, pkgs, pkgs-unstable, ... }: {
    programs.vscode = {
        enable = true;

        package = pkgs.vscodium;

        extensions = with pkgs-unstable.vscode-extensions; [
            # Misc
            aaron-bond.better-comments
            # vivaxy.vscode-conventional-commits
            mhutchie.git-graph
            gruntfuggly.todo-tree
            github.copilot

            # Debugger
            vadimcn.vscode-lldb

            # Nix
            bbenoist.nix
            mkhl.direnv

            # Rust
            bungcip.better-toml
            serayuzgur.crates
            rust-lang.rust-analyzer
        ];
    };

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".vscode-oss"
            ".config/VSCodium"
        ];
    };
}
