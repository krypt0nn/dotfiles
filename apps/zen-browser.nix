{ inputs, pkgs, ... }:
let
    zenPackages = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system};

    mkExtensionSettings = builtins.mapAttrs (_: slug: {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
        installation_mode = "force_installed";
    });

    # A policy preference is either a plain value or { Value; Status; } where
    # Status is default | locked | user | clear (see the schema shipped in
    # omni.ja:/modules/policies/policies-schema.json -- about:policies lists
    # whatever ends up active). "locked" is what makes Gecko apply the pref and
    # grey it out instead of treating it as a suggestion.
    lock = value: { Value = value; Status = "locked"; };

    policies = {
        ExtensionSettings = mkExtensionSettings {
            "uBlock0@raymondhill.net" = "ublock-origin";
            "jid1-MnnxcxisBPnSXQ@jetpack" = "privacy-badger17";
            "jid1-ZAdIEUB7XOzOJw@jetpack" = "duckduckgo-for-firefox";
            "sponsorBlocker@ajay.app" = "sponsorblock";
            "deArrow@ajay.app" = "dearrow";
            "firefox@betterttv.net" = "betterttv";
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
            "multithreaded-download-manager@qw.linux-2g64.local" = "multithreaded-download-manager";
        };

        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableThirdPartyModuleInject = true;

        # The dedicated Proxy policy is what Gecko also reflects in the
        # Settings > Network page (locked, showing the SOCKS entry); the raw
        # network.proxy.* prefs apply the same settings but leave that page
        # looking untouched. UseProxyForDNS = socks_remote_dns.
        Proxy = {
            Mode = "manual";
            SOCKSProxy = "127.0.0.1:1000";
            SOCKSVersion = 5;
            UseProxyForDNS = true;
            Locked = true;
        };

        Preferences = {
            # DoH would resolve names locally again, next to the proxy.
            "network.trr.mode" = lock 5;

            # SOCKS carries no WebRTC UDP candidates, so without this ICE
            # still offers the LAN address.
            "media.peerconnection.ice.no_host" = lock true;

            "browser.contentblocking.category" = lock "strict";
            "dom.security.https_only_mode" = lock true;
            "geo.enabled" = lock false;

            "browser.formfill.enable" = lock false;
            "extensions.formautofill.addresses.enabled" = lock false;
            "extensions.formautofill.creditCards.enabled" = lock false;

            "browser.urlbar.suggest.quicksuggest.nonsponsored" = lock false;
            "browser.urlbar.suggest.quicksuggest.sponsored" = lock false;
            "browser.newtabpage.activity-stream.showSponsored" = lock false;
            "browser.newtabpage.activity-stream.showSponsoredTopTabs" = lock false;
            "browser.discovery.enabled" = lock false;
        };
    };

    zenUnwrapped = zenPackages.beta-unwrapped.override { extraPolicies = policies; };

    # Same wrapper the flake's `default` package uses (it fixes wrapFirefox's
    # ffmpeg pick for Zen's odd version string), with the policies passed along
    # so both copies of policies.json agree.
    wrapZen = import "${inputs.zen-browser}/wrap-zen.nix" pkgs.wrapFirefox;
in {
    environment.systemPackages = [
        (wrapZen zenUnwrapped {
            icon = "zen-browser";
            extraPolicies = policies;
        })
    ];
}
