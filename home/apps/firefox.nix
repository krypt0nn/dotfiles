{ flakeConfig, pkgs, ... }: {
    programs.firefox = {
        enable = true;

        package = pkgs.firefox-wayland;

        policies = {
            HardwareAcceleration = true;

            DisableFirefoxStudies = true;
            DisablePocket = true;
            DisableTelemetry = true;

            settings = {
                "browser.search.defaultenginename" = "DuckDuckGo";
                "browser.search.order.1" = "DuckDuckGo";

                "extensions.pocket.enabled" = false;
                "browser.newtabpage.activity-stream.showSponsored" = false;
                "browser.newtabpage.activity-stream.system.showSponsored" = false;
                "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

                "widget.use-xdg-desktop-portal.file-picker" = 1;

                "media.ffmpeg.vaapi.enabled" = true;
                "media.ffvpx.enabled" = false;
                "media.av1.enabled" = false;
                "gfx.webrender.all" = true;
            };
        };
    };

    home.persistence."/persistent/home/${flakeConfig.username}" = {
        allowOther = false;

        directories = [
            ".mozilla"
        ];
    };
}
