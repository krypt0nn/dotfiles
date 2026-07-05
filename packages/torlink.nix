{ username, inputs, pkgs, ... }: {
    environment.systemPackages = [
        (pkgs.symlinkJoin {
            name = "torlink";
            paths = [ inputs.torlink.packages.${pkgs.stdenv.hostPlatform.system}.default ];
            postBuild = ''
                ln -sf torlnk "$out/bin/torlink"
            '';
        })
    ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".local/share/torlink"
        ];
    };
}
