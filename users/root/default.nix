{ pkgs, ... }: {
    imports = [
        # ./persistence.nix
    ];

    users.users.root = {
        createHome = true;

        shell = pkgs.bash;

        name = "root";
        home = "/root";

        uid = 0;

        hashedPasswordFile = "/persistent/root.password";
    };
}
