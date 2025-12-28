{ ... }: {
    # https://kaylorben.github.io/nixcord
    programs.nixcord = {
        enable = true;
        discord.vencord.enable = true;
        dorion.enable = true;

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

        dorion = {
            blur = "acrylic";
            sysTray = true;
            openOnStartup = true;
            autoClearCache = true;
            disableHardwareAccel = false;
            desktopNotifications = true;
        };
    };

    # home.persistence."/persistent" = {
    #     directories = [
    #         ".config/vesktop"
    #     ];
    # };
}
