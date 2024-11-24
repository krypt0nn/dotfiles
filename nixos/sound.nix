{ lib, pkgs, flakeConfig, ... }: {
    services.pipewire = {
        enable = true;

        jack.enable = true;
        pulse.enable = true;

        alsa = {
            enable = true;
            support32Bit = true;
        };

        # Configure latency
        # Source: https://github.com/fufexan/nix-gaming/blob/963803d3be8ed721b21326804513dec884e9d494/modules/pipewireLowLatency.nix

        extraConfig.pipewire = {
            "99-lowlatency" = {
                context = let qr = "${toString flakeConfig.pipewire.quantum}/${toString flakeConfig.pipewire.rate}"; in {
                    properties.default.clock.min-quantum = flakeConfig.pipewire.quantum;

                    modules = [
                        {
                            name = "libpipewire-module-rtkit";
                            flags = [ "ifexists" "nofail" ];

                            args = {
                                nice.level = -15;

                                rt = {
                                    prio = 88;
                                    time.soft = 200000;
                                    time.hard = 200000;
                                };
                            };
                        }

                        {
                            name = "libpipewire-module-protocol-pulse";

                            args = {
                                server.address = [ "unix:native" ];

                                pulse.min = {
                                    req = qr;
                                    quantum = qr;
                                    frag = qr;
                                };
                            };
                        }
                    ];

                    stream.properties = {
                        node.latency = qr;
                        resample.quality = 1;
                    };
                };
            };
        };

        wireplumber = {
            enable = true;

            configPackages = let
                matches = lib.generators.toLua {
                    multiline = false;
                    indent = false;
                } [[[ "node.name" "matches" "alsa_output.*" ]]];

                apply_properties = lib.generators.toLua {} {
                    "audio.format" = "S32LE";
                    "audio.rate" = flakeConfig.pipewire.rate * 2;
                    "api.alsa.period-size" = 2;
                };
            in [
                (pkgs.writeTextDir "share/lowlatency.lua.d/99-alsa-lowlatency.lua" ''
                    alsa_monitor.rules = {
                        {
                            matches = ${matches};
                            apply_properties = ${apply_properties};
                        }
                    }
                '')
            ];
        };
    };
}
