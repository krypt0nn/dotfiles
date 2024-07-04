{ inputs, flakeConfig, ... }: {
	nix.settings = inputs.aagl.nixConfig;

    home.packages = with inputs.aagl.packages.x86_64-linux; [
    	sleepy-launcher
    ];

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".local/share/sleepy-launcher"
        ];
    };
}
