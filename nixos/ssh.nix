{ ... }: {
    services.openssh = {
        enable = true;
        startWhenNeeded = true;

        settings = {
            AllowUsers = null;
            DenyUsers = [ "root" ];
        };
    };
}
