{ inputs, lib, pkgs, ... }:
let
    enableSsh = false;
    encryptedEnvFile = "/persistent/hermes/env";
    encryptedTokenFile = "/persistent/hermes/desktop-token";
    hermesGid = 59999;
in {
    imports = [ inputs.microvm.nixosModules.host ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/persistent/hermes"
        ];
    };

    networking.firewall.allowedTCPPorts = [ 9119 ];

    systemd.services.hermes-agent-decrypt-secrets = {
        before = [ "microvm-virtiofsd@hermes-agent.service" ];
        requiredBy = [ "microvm-virtiofsd@hermes-agent.service" ];

        unitConfig.ConditionPathExists = [
            encryptedEnvFile
            encryptedTokenFile
        ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;

            LoadCredentialEncrypted = [
                "HERMES_ENV:${encryptedEnvFile}"
                "HERMES_DESKTOP_TOKEN:${encryptedTokenFile}"
            ];

            StateDirectory = "secrets/hermes";
        };

        script = ''
            mkdir -p /run/secrets/hermes

            cat "$CREDENTIALS_DIRECTORY/HERMES_ENV" > /run/secrets/hermes/env
            printf '%s' "$(cat "$CREDENTIALS_DIRECTORY/HERMES_DESKTOP_TOKEN")" \
                > /run/secrets/hermes/desktop-token

            chmod 600 /run/secrets/hermes/env

            chgrp ${toString hermesGid} /run/secrets/hermes/desktop-token

            chmod 640 /run/secrets/hermes/desktop-token
        '';
    };

    microvm.vms.hermes-agent = {
        config = { ... }: {
            imports = [ inputs.hermes-agent.nixosModules.default ];

            networking.hostName = "hermes-agent";

            users.groups.hermes.gid = hermesGid;

            networking.firewall.allowedTCPPorts = [ 9119 ];

            microvm = {
                hypervisor = "qemu";
                vcpu = 4;
                mem = 4 * 1024;

                registerWithMachined = true;

                interfaces = [{
                    type = "user";
                    id = "hermes-agent0";
                    mac = "02:00:00:00:02:02";
                }];

                forwardPorts = lib.optionals enableSsh [{
                    from = "host";
                    host.port = 2222;
                    guest.port = 22;
                }] ++ [{
                    from = "host";
                    host.port = 9119;
                    guest.port = 9119;
                }];

                shares = [
                    {
                        proto = "virtiofs";
                        tag = "ro-store";
                        source = "/nix/store";
                        mountPoint = "/nix/.ro-store";
                    }
                    {
                        proto = "virtiofs";
                        tag = "hermes-secrets";
                        source = "/run/secrets/hermes";
                        mountPoint = "/run/secrets/hermes";
                        readOnly = true;
                    }
                ];

                volumes = [{
                    mountPoint = "/var";
                    image = "var.img";
                    size = 64 * 1024;
                }];
            };

            services.openssh = lib.mkIf enableSsh {
                enable = true;
                settings.PermitRootLogin = "yes";
                settings.PasswordAuthentication = true;
            };

            users.users.root.initialPassword = lib.mkIf enableSsh "hermes";

            services.journald = {
                storage = "volatile";
                extraConfig = "MaxRetentionSec=3day";
            };

            # The hermes module merges environmentFiles into $HERMES_HOME/.env
            # at activation — which runs in the initrd, BEFORE the hermes-secrets
            # virtiofs share is mounted. The merged .env therefore misses every
            # var from the share. Re-run activation (idempotent by design) once
            # the share is up, ordered ahead of both hermes services.
            systemd.services.hermes-env-merge = {
                description = "Re-run activation so .env includes the hermes-secrets share";
                unitConfig.RequiresMountsFor = "/run/secrets/hermes";
                wantedBy = [ "multi-user.target" ];
                before = [ "hermes-agent.service" "hermes-backend.service" ];
                requiredBy = [ "hermes-agent.service" "hermes-backend.service" ];
                serviceConfig = {
                    Type = "oneshot";
                    RemainAfterExit = true;
                };
                script = "/run/current-system/activate";
            };

            services.hermes-agent = {
                enable = true;
                addToSystemPackages = true;

                backend = {
                    mode = "serve";
                    host = "0.0.0.0";
                    port = 9119;
                    sessionTokenFile = "/run/secrets/hermes/desktop-token";
                };

                workingDirectory = "/var/lib/hermes/workspace";
                environmentFiles = [ "/run/secrets/hermes/env" ];

                environment = {
                    SEARXNG_URL = "http://10.0.2.2:8080";
                };

                settings = {
                    web.search_backend = "searxng";

                    model = {
                        provider = "custom";
                        base_url = "http://10.0.2.2:9931/v1";
                        default = "minicpm5-2b";
                    };
                };

                extraPackages = with pkgs; [
                    jq
                    curl
                    wget
                    unzip
                    file
                    which
                    fd
                    tree
                    python3
                    pandoc
                    imagemagick
                ];
            };

            system.stateVersion = "24.05";
        };
    };

    microvm.autostart = [ "hermes-agent" ];
}
