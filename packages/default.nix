{ hostname, ... }: {
    imports = let
        default = [
            ./fish.nix
            ./git.nix
            ./direnv.nix
            ./zoxide.nix
            ./fzf.nix
        ];
    in {
        "observer-pc" = default ++ [
            ./rust.nix
            ./llama-cpp.nix
            ./opencode.nix
            ./torlink.nix
        ];

        "observer-laptop" = default ++ [
            ./rust.nix
            ./opencode.nix
            ./torlink.nix
        ];

        "observer-server" = default;
    }.${hostname};
}
