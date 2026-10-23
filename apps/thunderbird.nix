{ ... }: {
    programs.thunderbird = {
        enable = true;

        policies = {
            DisableAppUpdate = true;

            Proxy = {
                Mode = "manual";
                SOCKSProxy = "127.0.0.1:1000";
                SOCKSVersion = 5;
                UseProxyForDNS = true;
                Locked = true;
            };

            DNSOverHTTPS.Enabled = false;
        };
    };
}
