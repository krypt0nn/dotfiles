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
    };

    outputs = {
        nixpkgs,
        nixpkgs-unstable,
        # nix-cachyos-kernel,
        impermanence,
        rust-overlay,
        nix-bwrapper,
        ...
    }@inputs:
        let
            flakeConfig = builtins.fromJSON (builtins.readFile ./config.json);

            system = "x86_64-linux";

            hostname = flakeConfig.hostname;
            username = flakeConfig.username;

            # with (import ./overlays.nix);
            overlays = [
                # Always use latest pre-compiled rust binaries
                rust-overlay.overlays.default

                nix-bwrapper.overlays.default

                # Add CachyOS kernels
                # nix-cachyos-kernel.overlays.default
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
                    inherit inputs hostname username pkgs-unstable;
                };

                modules = [
                    nixpkgs.nixosModules.readOnlyPkgs

                    { nixpkgs = { inherit pkgs; }; }

                    impermanence.nixosModules.impermanence

                    ./hosts
                    ./users
                    ./system
                    ./apps
                    ./packages
                ];
            };

            devShells.${system}.default = pkgs.mkShell {
                nativeBuildInputs = with pkgs; [ nixd nil ];
            };
        };
}
