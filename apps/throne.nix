{ pkgs, lib, ... }:
let
    # HACK: force-use latest throne before it gets merged to next stable nixos.
    throneNixpkgs = fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/af0f90757b55c7e5376102e9a36ff9e7eb38d156.tar.gz";
        sha256 = "19423vm0nf75zv47a00adm53rgrlvi4zpik5q75lvwc8mrzyff5n";
    };

    thronePkgs = import throneNixpkgs {
        inherit (pkgs.stdenv.hostPlatform) system;
        config = pkgs.config;
        overlays = pkgs.overlays or [];
    };
in {
    disabledModules = [ "programs/throne.nix" ];
    imports = [ "${throneNixpkgs}/nixos/modules/programs/throne.nix" ];

    config = {
        programs.throne = {
            package = thronePkgs.throne;
            enable = true;
            tunMode.enable = true;
        };
    };

    options.security.polkit.enablePkexecWrapper = lib.mkOption {
        type = lib.types.bool;
        default = true;
    };
}
