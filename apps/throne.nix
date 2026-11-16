{ pkgs, lib, ... }:
let
    # HACK: force-use latest throne before it gets merged to next stable nixos.
    throneNixpkgs = fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/b887b471411ad5c18728c8872e0d3b94e79a920e.tar.gz";
        sha256 = "1ci4qwzm0synvlsdlgnff9kpp6gc62m7g9dqjvzpf960iad2i6sa";
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
