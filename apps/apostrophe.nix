{ username, pkgs, ... }: {
    environment.systemPackages = [ pkgs.apostrophe ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".local/share/apostrophe"
        ];
    };
}
