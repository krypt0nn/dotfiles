{
    description = "System configuration flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/release-24.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        impermanence.url = "github:nix-community/impermanence";

        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };
    };

    outputs = { nixpkgs, nixpkgs-unstable, home-manager, impermanence, rust-overlay, ... }@inputs:
        let
            flakeConfig = builtins.fromJSON (builtins.readFile ./config.json);

            system = "x86_64-linux";

            pkgs = import nixpkgs {
                inherit system;

                config.allowUnfree = true;

                overlays = [ rust-overlay.overlays.default ];
            };

            pkgs-unstable = import nixpkgs-unstable {
                inherit system;

                config.allowUnfree = true;

                overlays = [ rust-overlay.overlays.default ];
            };

        in {
            nixosConfigurations.${flakeConfig.hostname} = nixpkgs.lib.nixosSystem {
                inherit system;

                specialArgs = {
                    inherit inputs;
                    inherit flakeConfig;
                    inherit pkgs;
                    inherit pkgs-unstable;
                };

                modules = [
                    ./nixos
                    ./hosts
                    ./users

                    impermanence.nixosModules.impermanence

                    home-manager.nixosModules.home-manager {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;

                        home-manager.users.${flakeConfig.username} = import ./home;

                        home-manager.extraSpecialArgs = {
                            inherit inputs;
                            inherit flakeConfig;
                            inherit pkgs;
                            inherit pkgs-unstable;
                        };
                    }
                ];
            };
        };
}
