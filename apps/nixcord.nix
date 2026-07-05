{ username, inputs, ... }: {
    imports = [ inputs.nixcord.nixosModules.nixcord ];

    programs.nixcord = {
        enable = true;
        vesktop.enable = true;
        discord.enable = false;

        user = username;

        config = {
            frameless = true;

            plugins = {
                anonymiseFileNames.enable = true;
                alwaysTrust.enable = true;
                betterGifPicker.enable = true;
                forceOwnerCrown.enable = true;
                showMeYourName.enable = true;
                messageLatency.enable = true;
                messageLogger.enable = true;
                imageFilename.enable = true;
                imageZoom.enable = true;
                noUnblockToJump.enable = true;
                silentTyping.enable = true;
                whoReacted.enable = true;
                validUser.enable = true;
                summaries.enable = true;
                serverInfo.enable = true;
                showHiddenChannels.enable = true;
                showHiddenThings.enable = true;
                webScreenShareFixes.enable = true;
            };
        };
    };
}
