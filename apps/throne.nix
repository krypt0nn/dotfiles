{ pkgs, lib, ... }:
let
    # HACK: force-use latest throne before it gets merged to next stable nixos.
    throneNixpkgs = fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/1ce1b790d81450e14568ab7663bfc0f4e6103d87.tar.gz";
        sha256 = "0p3vvxk6v251afyixap8alawx4v06r730kvwrsi08fa8g9jif215";
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
