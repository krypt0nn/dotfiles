{ enableImpermanence, ... }: {
    programs.git = {
        enable = true;

        config = {
            user = {
                name = "Nikita Podvirnyi";
                email = "krypt0nn@dawn.wine";
                signingkey = "~/.ssh/id_ed25519.pub";
            };

            commit.gpgsign = true;
            gpg.format = "ssh";

            init.defaultBranch = "master";
            advice.defaultBranchName = false;

            # HACK
            safe.directory = if enableImpermanence
                then "/system-flake"
                else "/etc/nixos";
        };
    };
}
