{ flakeConfig, pkgs-unstable, ... }: {
    home.packages = with pkgs-unstable; [
        cargo
        clippy
        rustc
        rustfmt
    ];

    home.sessionVariables = {
        RUST_SRC_PATH = "${pkgs-unstable.rust.packages.stable.rustPlatform.rustLibSrc}";
        RUST_BACKTRACE = 1;
    };

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".rustup"
            ".cargo"
        ];
    };
}
