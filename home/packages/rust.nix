{ pkgs-unstable, ... }: {
    home.packages = with pkgs-unstable; [
        (rust-bin.stable.latest.default.override {
            extensions = [
                "rust-src"
                "rust-analyzer"
                "clippy"
            ];
        })
    ];

    home.sessionVariables.RUST_BACKTRACE = 1;

    home.persistence."/persistent" = {
        directories = [
            ".rustup"
            ".cargo"
        ];
    };
}
