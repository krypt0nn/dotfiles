{
    description = "System configuration flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/release-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        impermanence = {
            url = "github:nix-community/impermanence";
            inputs = {
                nixpkgs.follows = "nixpkgs";
                home-manager.follows = "nixpkgs";
            };
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
    };

    outputs = {
        nixpkgs,
        nixpkgs-unstable,
        home-manager,
        impermanence,
        rust-overlay, ...
    }@inputs:
        let
            flakeConfig = builtins.fromJSON (builtins.readFile ./config.json);

            system = "x86_64-linux";

            hostname = flakeConfig.hostname;
            username = flakeConfig.username;

            overlays = with (import ./overlays.nix); [
                # Always use latest pre-compiled rust binaries.
                rust-overlay.overlays.default

                # Finally got throne update :xdd:
                #
                # https://github.com/NixOS/nixpkgs/pull/475843
                # https://github.com/NixOS/nixpkgs/commit/e5d943983efb1dfdeba7c02d1f54344158d4e677
                (pin {
                    pkg = "throne";
                    rev = "e5d943983efb1dfdeba7c02d1f54344158d4e677";
                    hash = "05hvs4sj1y77qwxh0sq9sw1jjj86k51b48dzhpxchj7y32gx4wf4";
                })

                # Pin tun2proxy binary because it broke upstream
                #
                # The error is:
                #   [ERROR tproxy_config::common] Failed to set up TProxy: routing loop detected
                #   [ERROR tun2proxy_bin] main loop error: routing loop detected
                #   Error: Custom { kind: Other, error: "routing loop detected" }
                #
                # Caused by tproxy-config update: https://github.com/tun2proxy/tproxy-config/commit/be337437195e5ede08b589308e8ddf4ccbacf431
                # Which prevents tun2proxy to be used with locally served proxies
                # (pin {
                #     pkg = "tun2proxy";
                #     rev = "b5cb7e25685cf4256f070edc3ea7791c8cd21613";
                #     hash = "zwI4xXLLkCMmW3+OBTE7M0quE8G15ynJVBOrWs2uLe4=";
                # })

                # Overlay some apps to use local proxy.
                # (proxy { pkg = "vesktop"; proxy = "socks5://127.0.0.1:11050"; })
                # (proxy { pkg = "fragments"; proxy = "socks5://127.0.0.1:9050"; })
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
            nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
                specialArgs = {
                    inherit inputs hostname username pkgs-unstable;
                };

                modules = [
                    nixpkgs.nixosModules.readOnlyPkgs

                    { nixpkgs = { inherit pkgs; }; }

                    impermanence.nixosModules.impermanence

                    ./hosts
                    ./users
                    ./nixos

                    home-manager.nixosModules.home-manager {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;

                        home-manager.users.${username} = import ./home;

                        home-manager.extraSpecialArgs = {
                            inherit inputs hostname username pkgs pkgs-unstable;
                        };
                    }
                ];
            };

            devShells.${system}.default = pkgs.mkShell {
                nativeBuildInputs = with pkgs; [ nixd nil ];
            };
        };
}
