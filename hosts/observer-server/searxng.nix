{ ... }:
let
    useTorProxy = false;
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
                enable_metrics = false;
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
                { name = "bing"; shortcut = "bi"; disabled = false; }
                { name = "mojeek"; shortcut = "mj"; disabled = false; }
                { name = "qwant"; shortcut = "qw"; disabled = false; }
                { name = "wikipedia"; shortcut = "wp"; disabled = false; }
            ];

            outgoing = if useTorProxy then {
                proxies = {
                    "all://" = [ "socks5h://127.0.0.1:9050" ];
                };
            } else {};
        };

        environmentFile = "/persistent/searx/secret";
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/persistent/searx"
        ];
    };
}
