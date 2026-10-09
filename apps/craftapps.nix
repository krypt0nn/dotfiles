{ inputs, ... }: {
    imports = [ inputs.nix-craftapps.nixosModules.default ];

    programs.craftapps = {
        enable = true;
        apps = {
            photocraft.enable = true;
            filmcraft.enable = true;
        };
    };
}
