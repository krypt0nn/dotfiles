{ flakeConfig, system, inputs, ... }: {
    home.packages = [
        inputs.zen-browser.packages.${system}.default
    ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".zen"
        ];
    };
}
