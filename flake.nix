{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        impermanence = {
            url = "github:nix-community/impermanence";
            inputs = {
                nixpkgs.follows = "";
                home-manager.follows = "";
            };
        };

        # nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };

        zen-browser.url = "github:0xc000022070/zen-browser-flake";

        nixcord = {
            url = "github:kaylorben/nixcord";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nix-bwrapper.url = "github:Naxdy/nix-bwrapper";

        anime-games-launcher.url = "github:an-anime-team/anime-games-launcher/next";
    };

    outputs = {
        nixpkgs,
        nixpkgs-unstable,
        # nix-cachyos-kernel,
        impermanence,
        rust-overlay,
        nix-bwrapper,
        anime-games-launcher,
        ...
    }@inputs:
        let
            system = "x86_64-linux";

            username = "observer";
            hostname = "observer-pc";

            # with (import ./overlays.nix);
            overlays = [
                # Always use latest pre-compiled rust binaries
                rust-overlay.overlays.default

                nix-bwrapper.overlays.default

                # Add CachyOS kernels (pinned for guaranteed binary cache)
                # nix-cachyos-kernel.overlays.pinned
            ];

            config = {
                allowUnfree = true;
                # rocmSupport = true;
            };

            pkgs = import nixpkgs {
                inherit system config overlays;
            };

            pkgs-unstable = import nixpkgs-unstable {
                inherit system config overlays;
            };

        in {
            nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
                specialArgs = {
                    inherit inputs username hostname pkgs-unstable;
                };

                modules = [
                    nixpkgs.nixosModules.readOnlyPkgs

                    { nixpkgs = { inherit pkgs; }; }

                    impermanence.nixosModules.impermanence
                    anime-games-launcher.nixosModules.anime-games-launcher

                    ./hosts
                    ./system
                    ./packages
                    ./apps
                ];
            };

            devShells.${system}.default = pkgs.mkShell {
                nativeBuildInputs = with pkgs; [ nixd nil ];
            };
        };
}
