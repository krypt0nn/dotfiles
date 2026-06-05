{ username, pkgs-unstable, ... }: {
    environment.systemPackages = [
        (pkgs-unstable.rust-bin.stable.latest.default.override {
            extensions = [
                "rust-src"
                "rust-analyzer"
                "clippy"
            ];
        })
    ];

    environment.variables.RUST_BACKTRACE = 1;

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".rustup"
            ".cargo"
        ];
    };
}
