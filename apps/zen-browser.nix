{ inputs, pkgs, ... }:
let
    zen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;

    mkExtensionSettings = builtins.mapAttrs (_: slug: {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
        installation_mode = "force_installed";
    });
in {
    environment.systemPackages = [
        (zen.override {
            extraPolicies = {
                ExtensionSettings = mkExtensionSettings {
                    "uBlock0@raymondhill.net" = "ublock-origin";
                    "jid1-MnnxcxisBPnSXQ@jetpack" = "privacy-badger17";
                    "jid1-ZAdIEUB7XOzOJw@jetpack" = "duckduckgo-for-firefox";
                    "sponsorBlocker@ajay.app" = "sponsorblock";
                    "deArrow@ajay.app" = "dearrow";
                    "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "return-youtube-dislikes";
                    "firefox@betterttv.net" = "betterttv";
                    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
                    "multithreaded-download-manager@qw.linux-2g64.local" = "multithreaded-download-manager";
                };

                DisableTelemetry = true;
                DisableFirefoxStudies = true;
                DisablePocket = true;
                DisableThirdPartyModuleInject = true;

                Preferences = {
                    "browser.contentblocking.category" = {
                        Value = "strict";
                        Status = "locked";
                    };

                    "dom.security.https_only_mode" = true;
                    "geo.enabled" = false;

                    "browser.formfill.enable" = false;
                    "extensions.formautofill.addresses.enabled" = false;
                    "extensions.formautofill.creditCards.enabled" = false;

                    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
                    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
                    "browser.newtabpage.activity-stream.showSponsored" = false;
                    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
                    "browser.discovery.enabled" = false;
                };
            };
        })
    ];
}
