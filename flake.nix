{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        # nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

        impermanence = {
            url = "github:nix-community/impermanence";
            inputs = {
                nixpkgs.follows = "";
                home-manager.follows = "";
            };
        };

        microvm = {
            url = "github:microvm-nix/microvm.nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nixpak = {
            url = "github:nixpak/nixpak";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };

        zen-browser.url = "github:0xc000022070/zen-browser-flake";

        nixcord = {
            url = "github:kaylorben/nixcord";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        torlink.url = "github:baairon/torlink";

        anime-games-launcher.url = "github:an-anime-team/anime-games-launcher/next";

        chekist.url = "git+https://dawn.wine/dawn-winery/chekist";
    };

    outputs = {
        nixpkgs,
        nixpkgs-unstable,
        # nix-cachyos-kernel,
        impermanence,
        rust-overlay,
        anime-games-launcher,
        chekist,
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

                # Add CachyOS kernels (pinned for guaranteed binary cache)
                # nix-cachyos-kernel.overlays.pinned
            ];

            config = {
                allowUnfree = true;
                # rocmSupport = true;
            };

            pkgs = import nixpkgs {
                inherit config overlays;

                localSystem = { inherit system; };
            };

            pkgs-unstable = import nixpkgs-unstable {
                inherit config overlays;

                localSystem = { inherit system; };
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
                    chekist.nixosModules.default

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
