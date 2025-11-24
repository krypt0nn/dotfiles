{ flakeConfig, ... }: {
    # https://kaylorben.github.io/nixcord
    programs.nixcord = {
        enable = true;

        config = {
            frameless = true;

            plugins = {
                anonymiseFileNames.enable = true;
                forceOwnerCrown.enable = true;
                showMeYourName.enable = true;
                messageLatency.enable = true;
                messageLogger.enable = true;
                noUnblockToJump.enable = true;
                silentTyping.enable = true;
                whoReacted.enable = true;
                validUser.enable = true;
                summaries.enable = true;
                webScreenShareFixes.enable = true;
            };
        };
    };

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".config/vesktop"
        ];
    };
}
