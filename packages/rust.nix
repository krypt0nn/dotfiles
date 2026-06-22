{ username, pkgs, pkgs-unstable, ... }: {
    environment.systemPackages = with pkgs; [
        gcc

        (pkgs-unstable.rust-bin.stable.latest.default.override {
            targets = [
                "x86_64-unknown-linux-gnu"
                "x86_64-unknown-linux-musl"
            ];

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
            ".cargo"
        ];
    };
}
