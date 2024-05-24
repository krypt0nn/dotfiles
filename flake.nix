{
    description = "System configuration flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/release-23.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs@{ nixpkgs, home-manager, ... }:
        let flakeConfig = {
            username = "observer";
            hostname = "observer-pc";
        };

        in {
            nixosConfigurations = {
                "observer-pc" = nixpkgs.lib.nixosSystem {
                    system = "x86_64-linux";

                    specialArgs = {
                        inherit inputs;
                        inherit flakeConfig;
                    };

                    modules = [
                        ./nixos/system.nix
                        ./hosts
                        ./users

                        # ./hosts/observer-pc/hardware.nix
                        # ./hosts/observer-pc/misc.nix
                        # ./hosts/observer-pc/services.nix
                        # ./users/observer

                        home-manager.nixosModules.home-manager {
                            home-manager.useGlobalPkgs = true;
                            home-manager.useUserPackages = true;

                            home-manager.users.observer = import ./home;

                            home-manager.extraSpecialArgs = {
                                inherit inputs;
                                inherit flakeConfig;
                            };
                        }
                    ];
                };
            };
        };
}
