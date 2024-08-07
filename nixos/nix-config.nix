{ pkgs, ... }: {
    nix = {
        package = pkgs.nix;

        settings = {
            experimental-features = [
                "nix-command"
                "flakes"
            ];

            substituters = [
                "https://cache.nixos.org"
                "https://nix-community.cachix.org"
            ];

            trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
        };

        optimise = {
            automatic = true;
            dates = [ "weekly" ];
        };

        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 14d";
        };
    };

    environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
}
