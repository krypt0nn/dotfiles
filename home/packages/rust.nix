{ flakeConfig, pkgs-unstable, ... }: {
    home.packages = with pkgs-unstable; [
        rustup
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
