{ flakeConfig, pkgs-unstable, ... }: {
    home.packages = with pkgs-unstable; [
        (rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" ];
        })
    ];

    home.sessionVariables.RUST_BACKTRACE = 1;

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".rustup"
            ".cargo"
        ];
    };
}
