{
    description = "System configuration flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/release-24.11";
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

            overlays = with (import ./overlays.nix); [
                # Always use latest pre-compiled rust binaries.
                rust-overlay.overlays.default

                # Pin apps to specific versions.
                (pin { pkg = "mission-center"; rev = "4cb4d316e68938d454977d8181a1501445ce6320"; ref = "release-24.11"; })

                # Overlay some apps to use local proxy.
                (proxy { pkg = "vesktop"; proxy = "socks5://127.0.0.1:11050"; electron = true; })
                (proxy { pkg = "fragments"; proxy = "socks5://127.0.0.1:9050"; })
            ];

            config = {
                allowUnfree = true;
            };

            pkgs = import nixpkgs {
                inherit system config overlays;
            };

            pkgs-unstable = import nixpkgs-unstable {
                inherit system config overlays;
            };

        in {
            nixosConfigurations.${flakeConfig.hostname} = nixpkgs.lib.nixosSystem {
                inherit system;

                specialArgs = {
                    inherit inputs flakeConfig pkgs pkgs-unstable;
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
                            inherit inputs flakeConfig pkgs pkgs-unstable;
                        };
                    }
                ];
            };

            devShells.${system}.default = pkgs.mkShell {
                nativeBuildInputs = [ pkgs.nixd ];
            };
        };
}
