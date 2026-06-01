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
                signingkey = "3B14311A878F6C8817482002859D416E5142AFF3";
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
