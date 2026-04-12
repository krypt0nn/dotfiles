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
                "https://cache.garnix.io"
            ];

            trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
            ];
        };

        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 28d";
        };
    };

    systemd.services.nix-daemon.environment = {
        TMPDIR = "/var/tmp";
    };

    environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
}
