{ flakeConfig, pkgs, ... }: {
    programs.vscode = {
        enable = true;

        package = pkgs.vscodium;

        extensions = with pkgs.vscode-extensions; [
            # Misc
            # aaron-bond.better-comments
            # vivaxy.vscode-conventional-commits
            mhutchie.git-graph
            gruntfuggly.todo-tree

            # Debugger
            vadimcn.vscode-lldb

            # Nix
            bbenoist.nix

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
        ];
    };
}
