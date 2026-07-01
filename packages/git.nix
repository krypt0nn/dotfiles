{ ... }: {
    programs.git = {
        enable = true;

        config = {
            init = {
                defaultBranch = "master";
            };

            advice = {
                defaultBranchName = false;
            };

            user = {
                name = "Nikita Podvirnyi";
                email = "krypt0nn@vk.com";
                signingkey = "~/.ssh/id_ed25519.pub";
            };

            gpg = {
                format = "ssh";
            };

            commit = {
                gpgsign = true;
            };

            safe = {
                directory = "/system-flake";
            };
        };
    };
}
