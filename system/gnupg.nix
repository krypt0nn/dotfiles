{ username, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        gnupg
        gnupg1compat
    ];

    programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            { directory = ".gnupg"; mode = "0700"; }
        ];
    };
}
