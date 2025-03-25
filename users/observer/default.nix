{ pkgs, ... }: {
    imports = [
        ./persistence.nix
        ./syncthing.nix
    ];

    users.users.observer = {
        isNormalUser = true;
        createHome = true;

        # useDefaultShell = true; # Doesn't work for whatever reason
        shell = pkgs.fish;

        name = "observer";
        home = "/home/observer";

        hashedPasswordFile = "/persistent/observer.password";

        extraGroups = [
            "wheel"
            "networkmanager"
            "libvirtd"
            "podman"
            "gamemode"
        ];
    };
}
