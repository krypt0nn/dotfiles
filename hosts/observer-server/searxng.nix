{ ... }:
let
    useTorProxy = true;
in {
    services.searx = {
        enable = true;
        openFirewall = true;

        settings = {
            server = {
                port = 8080;
                bind_address = "0.0.0.0";
                secret_key = "$SEARX_SECRET_KEY";
                method = "GET";
                image_proxy = useTorProxy;
            };

            general = {
                debug = false;
                donation_url = false;
                contact_url = false;
                privacypolicy_url = false;
                enable_metrics = true;
            };

            ui = {
                default_locale = "en";
                default_theme = "simple";
                static_use_hash = true;
                query_in_title = true;
                center_alignment = true;
            };

            search = {
                formats = [ "html" "json" ];
                autocomplete = "duckduckgo";
            };

            engines = [
                # Enabled: measured working through the Tor egress.
                { name = "mwmbl"; disabled = false; }
                { name = "fynd"; disabled = false; }
                { name = "gmx"; disabled = false; }
                { name = "encyclosearch"; disabled = false; }
                { name = "wiby"; disabled = false; }
                { name = "yacy"; disabled = false; }
                { name = "seznam"; disabled = false; }
                { name = "wikinews"; disabled = false; }
            ] ++ (if useTorProxy then [
                # Only dead on Tor exits; on a direct connection let them try.
                { name = "duckduckgo"; disabled = true; }
                { name = "qwant"; disabled = true; }
                { name = "startpage"; disabled = true; }
                { name = "brave"; disabled = true; }
                { name = "presearch"; disabled = true; }
                { name = "sogou"; disabled = true; }
            ] else []);

            outgoing = {
                request_timeout = 8.0;
                max_request_timeout = 20.0;
            } // (if useTorProxy then {
                proxies = {
                    "all://" = [ "socks5h://127.0.0.1:9050" ];
                };
                using_tor_proxy = true;
                extra_proxy_timeout = 10;
            } else {});
        };

        environmentFile = "/persistent/searx.secrets";
    };
}
