{ ... }: {
    users.users = {
        observer = {
            isNormalUser = true;

            name = "observer";
            home = "/home/observer";

            extraGroups = [
                "wheel"
                "networkmanager"
                "libvirtd"
            ];
        };
    };
}
