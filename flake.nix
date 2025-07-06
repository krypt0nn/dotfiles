{
    description = "System configuration flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/release-25.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        impermanence.url = "github:nix-community/impermanence";

        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };

        zen-browser.url = "github:0xc000022070/zen-browser-flake";
    };

    outputs = { nixpkgs, nixpkgs-unstable, home-manager, impermanence, rust-overlay, ... }@inputs:
        let
            flakeConfig = builtins.fromJSON (builtins.readFile ./config.json);

            system = "x86_64-linux";

            overlays = with (import ./overlays.nix); [
                # Always use latest pre-compiled rust binaries.
                rust-overlay.overlays.default

                # Overlay some apps to use local proxy.
                (proxy { pkg = "vesktop"; proxy = "socks5://127.0.0.1:11050"; })
                (proxy { pkg = "fragments"; proxy = "socks5://127.0.0.1:9050"; })

                # Temporary workaround for ghostty performance regression.
                # Link: https://github.com/ghostty-org/ghostty/discussions/7720
                (self: super: {
                    ghostty = super.ghostty.overrideAttrs (_: {
                        preBuild = ''
                            shopt -s globstar
                            sed -i 's/^const xev = @import("xev");$/const xev = @import("xev").Epoll;/' **/*.zig
                            shopt -u globstar
                        '';
                    });
                })
            ];

            config = {
                allowUnfree = true;
                rocmSupport = true;
            };

            pkgs = import nixpkgs {
                inherit system config overlays;
            };

            pkgs-unstable = import nixpkgs-unstable {
                inherit system config overlays;
            };

        in {
            nixosConfigurations.${flakeConfig.hostname} = nixpkgs.lib.nixosSystem {
                specialArgs = {
                    inherit system inputs flakeConfig pkgs-unstable;
                };

                modules = [
                    nixpkgs.nixosModules.readOnlyPkgs

                    { nixpkgs = { inherit pkgs; }; }

                    ./hosts
                    ./users
                    ./nixos

                    impermanence.nixosModules.impermanence

                    home-manager.nixosModules.home-manager {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;

                        home-manager.users.${flakeConfig.username} = import ./home;

                        home-manager.extraSpecialArgs = {
                            inherit system inputs flakeConfig pkgs pkgs-unstable;
                        };
                    }
                ];
            };

            devShells.${system}.default = pkgs.mkShell {
                nativeBuildInputs = [ pkgs.nixd ];
            };
        };
}
