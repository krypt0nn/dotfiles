{ inputs, pkgs, ... }: {
    home.packages = [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home.persistence."/persistent" = {
        directories = [
            ".zen"
        ];
    };
}
