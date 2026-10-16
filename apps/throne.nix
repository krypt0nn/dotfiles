{ pkgs, lib, ... }:
let
    # HACK: force-use latest throne before it gets merged to next stable nixos.
    throneNixpkgs = fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/30d4c9866718bfa88fff675ba5c9901e45a82f5f.tar.zst";
        sha256 = "1d8jmyqd458g5ymm4ab223d49330qmqw39bjybjizsb99hf9h61i";
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
