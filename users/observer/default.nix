{ pkgs, ... }: {
    imports = [
        ./persistence.nix
        ./syncthing.nix
    ];

    users.users.observer = {
        isNormalUser = true;

        # useDefaultShell = true; # Doesn't work for whatever reason
        shell = pkgs.zsh;

        name = "observer";
        home = "/home/observer";

        extraGroups = [
            "wheel"
            "networkmanager"
            "libvirtd"
            "podman"
        ];
    };
}
