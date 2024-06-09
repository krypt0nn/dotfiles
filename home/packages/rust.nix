{ pkgs-unstable, ... }: {
    home.packages = with pkgs-unstable; [
        cargo
        clippy
    ];

    home.sessionVariables = {
        RUST_SRC_PATH = "${pkgs-unstable.rust.packages.stable.rustPlatform.rustLibSrc}";
        RUST_BACKTRACE = 1;
    };
}
