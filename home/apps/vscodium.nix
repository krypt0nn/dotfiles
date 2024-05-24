{ pkgs, ... }: {
    programs.vscode = {
        enable = true;

        # package = pkgs.vscodium.fhsWithPackages (pkgs: with pkgs; [
        #     cargo
        #     clippy
        # ]);

        package = pkgs.vscodium.fhs;

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
}
