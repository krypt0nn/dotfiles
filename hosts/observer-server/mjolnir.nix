{ ... }: {
    # Enable matrix server moderation bot.
    services.mjolnir = {
        enable = true;

        homeserverUrl = "https://matrix.envs.net"; # "https://mozilla.modular.im";
        managementRoom = "!VVpzPiaLqqNcyYwyYL:mozilla.org";

        pantalaimon.username = "nobody";
        accessTokenFile = "/persistent/mjolnir.token";

        protectedRooms = [
            # Home
            "https://matrix.to/#/!BMRQVHWqaOwRxvneVP:mozilla.org" # announcements
            "https://matrix.to/#/!bLZJwKIaHObEdyGpUG:mozilla.org" # matrix-general

            # Launcher
            "https://matrix.to/#/!gTxhfDumTUnnXPNsgN:mozilla.org" # ban-reports
            "https://matrix.to/#/!aewIKgEVBbKhAITsVy:mozilla.org" # support
            "https://matrix.to/#/!tdNhhDEOUdzWxQTBnM:mozilla.org" # dev

            # General
            "https://matrix.to/#/!OYrlbTulLPxRtwyqBB:mozilla.org" # general
            "https://matrix.to/#/!wqMhuAUabtkPxVsZeI:mozilla.org" # linux-stuff
            "https://matrix.to/#/!vnJwHsLqoTLnLvlTnY:mozilla.org" # steam-deck
            "https://matrix.to/#/!PGNKXOwACmkKwssqpE:mozilla.org" # memes
            "https://matrix.to/#/!BmdwonAjvWaiSzugBy:mozilla.org" # anime
            "https://matrix.to/#/!vfZjbQtYVWNNxXWTXC:mozilla.org" # games
            "https://matrix.to/#/!LghLZoXFbebTtsetNJ:mozilla.org" # music
            "https://matrix.to/#/!jLExSAyuqozyNSfvmM:mozilla.org" # studies

            # Genshin Impact
            "https://matrix.to/#/!iwbOkdIKNEuSkCilbS:mozilla.org" # genshin-leaks
            "https://matrix.to/#/!mADgGjDIkXiSLdZoZu:mozilla.org" # genshin-general
            "https://matrix.to/#/!diTrCWOgXgUEJFgXmE:mozilla.org" # genshin-codes
            "https://matrix.to/#/!LSwKkaeXBybcDomqzW:mozilla.org" # genshin-announcements

            # Zenless Zone Zero
            "https://matrix.to/#/!OhGqaGGhvWFvkubxAy:mozilla.org" # zzz-leaks
            "https://matrix.to/#/!spwrxfauCJsJIaPyfY:mozilla.org" # zzz-general
            "https://matrix.to/#/!WCQyjHscKRYJarrTAg:mozilla.org" # zzz-codes
            "https://matrix.to/#/!hhuwQOXNMsSlcHMgxF:mozilla.org" # zzz-announcements

            # Honkai: Star Rail
            "https://matrix.to/#/!LoMSkPdfimqTVcWMLT:mozilla.org" # hsr-leaks
            "https://matrix.to/#/!DveixVWbGlZtHLMqsP:mozilla.org" # hsr-general
            "https://matrix.to/#/!BIJOeoTLsnQnmZsqmh:mozilla.org" # hsr-codes
            "https://matrix.to/#/!mguppmgtFjBZPqEylc:mozilla.org" # hsr-announcements

            # Honkai Impact 3rd
            "https://matrix.to/#/!iCPgDckspMVHHrxNBr:mozilla.org" # honkai-leaks
            "https://matrix.to/#/!eJJPxpkYAldbeqrkRq:mozilla.org" # honkai-general
            "https://matrix.to/#/!xVkXSelfRLXvuaKQqx:mozilla.org" # honkai-codes
            "https://matrix.to/#/!MxtMnFUwDZfSBNSTiJ:mozilla.org" # honkai-announcements

            # Wuthering Waves
            "https://matrix.to/#/!mUhvZYQPGgdkbySRYm:mozilla.org" # wuwa-leaks
            "https://matrix.to/#/!JAZNafxVWNBWrgYywL:mozilla.org" # wuwa-general
            "https://matrix.to/#/!OcwlDBkQIlqAVOpYzt:mozilla.org" # wuwa-codes
            "https://matrix.to/#/!tlWwGkKzAPPGSdHTJK:mozilla.org" # wuwa-announcements

            # Foreigners Native
            "https://matrix.to/#/!EhKswsMrDAEOviheKu:mozilla.org" # Chinese
            "https://matrix.to/#/!hYNoWsYjSECoDeUETd:mozilla.org" # Japanese
            "https://matrix.to/#/!PLucqCdzufiOTEMNjp:mozilla.org" # Italian
            "https://matrix.to/#/!nDusXXoheHBzhUyfLl:mozilla.org" # Spanish
            "https://matrix.to/#/!oGbVtrWcSXebCgkprR:mozilla.org" # Portuguese
            "https://matrix.to/#/!XmkdtmnOlHsYJYCEqf:mozilla.org" # French
            "https://matrix.to/#/!DVZHoEsMnRCNeLitsf:mozilla.org" # German
            "https://matrix.to/#/!nKKcYHfwLdOcuOnEfN:mozilla.org" # Russian
        ];

        settings = {
            displayReports = true;
            nsfwSensitivity = 0.6;
        };
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/var/lib/mjolnir"
        ];
    };
}
