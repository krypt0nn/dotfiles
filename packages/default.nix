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
            ./pi-agent.nix
            ./torlink.nix
        ];

        "observer-laptop" = default ++ [
            ./rust.nix
            ./pi-agent.nix
            ./torlink.nix
        ];

        "observer-server" = default;
    }.${hostname};
}
