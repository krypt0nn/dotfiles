{
    description = "System configuration flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/release-23.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # bcachefs-tools = {
        #     url = "github:koverstreet/bcachefs-tools";
        #     inputs.nixpkgs.follows = "nixpkgs";
        # };
    };

    outputs = { nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
        let
            flakeConfig = {
                username = "observer";
                hostname = "observer-pc";
            };

            system = "x86_64-linux";

            pkgs = import nixpkgs {
                inherit system;

                config.allowUnfree = true;
            };

            pkgs-unstable = import nixpkgs-unstable {
                inherit system;

                config.allowUnfree = true;
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
