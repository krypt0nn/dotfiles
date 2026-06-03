{ username, pkgs, ... }: {
    environment.systemPackages = [ pkgs.amberol ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            ".cache/amberol"
        ];
    };
}
