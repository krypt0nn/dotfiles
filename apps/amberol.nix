{ pkgs, ... }: {
    environment.systemPackages = [ pkgs.amberol ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.observer = {
            directories = [
                ".cache/amberol"
            ];
        };
    };
}
