{ pkgs, ... }: {
    nix = {
        package = pkgs.nix;

        settings = {
            auto-optimise-store = true;
            builders-use-substitutes = true;

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

        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 14d";
        };
    };

    environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
}
