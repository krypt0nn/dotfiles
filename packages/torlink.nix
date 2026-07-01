{ username, inputs, pkgs, ... }: {
    environment.systemPackages = [
        inputs.torlink.packages.${pkgs.system}.default
    ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".local/share/torlink"
        ];
    };
}
