{ pkgs, lib, ... }:
let
    # HACK: force-use latest throne before it gets merged to next stable nixos.
    throneNixpkgs = fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/62fae0242370ae97c3721003a32366a0cba3a96e.tar.gz";
        sha256 = "0hpnspsik1ssc1l7a5vxglknycazrvr9j5yy1x0r0q6mfax2kinm";
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
