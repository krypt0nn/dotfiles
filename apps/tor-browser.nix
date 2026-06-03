{ username, pkgs, ... }: {
    environment.systemPackages = [ pkgs.tor-browser ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".tor project"
        ];
    };
}
