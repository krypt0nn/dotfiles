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

        nixcord = {
            url = "github:kaylorben/nixcord";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        zen-browser = {
            url = "github:0xc000022070/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        torlink = {
            url = "github:baairon/torlink";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        anime-games-launcher.url = "github:an-anime-team/anime-games-launcher";
        chekist.url = "git+https://dawn.wine/dawn-winery/chekist";
    };

    outputs = {
        nixpkgs,
        nixpkgs-unstable,
        # nix-cachyos-kernel,
        impermanence,
        rust-overlay,
        ...
    }@inputs:
        let
            system = "x86_64-linux";

            username = "observer";
            hostname = "observer-pc";

            # HACK: I want to go away from impermanence at some point, but I
            # also don't want to reinstall the system on all my devices. So for
            # now I use this flag to mark impermanence-powered devices.
            enableImpermanence = true;

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
                    inherit inputs username hostname enableImpermanence pkgs-unstable;
                };

                modules = [
                    nixpkgs.nixosModules.readOnlyPkgs

                    { nixpkgs = { inherit pkgs; }; }

                    # HACK: use stub impermanence module in non-impermanence
                    # setups to keep all the existing files unchanged.
                    (if enableImpermanence
                        then impermanence.nixosModules.impermanence
                        else {
                            options.environment.persistence = nixpkgs.lib.mkOption {
                                type = nixpkgs.lib.types.attrsOf nixpkgs.lib.types.anything;
                                default = {};
                                apply = _: {};
                            };
                        })

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
