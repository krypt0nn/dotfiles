{ inputs, lib, ... }:
let
    enableSsh = false;
    orgOnlyAccess = false;
    encryptedAgentSecret = "/persistent/crow/agent-secret";
    encryptedRegistryToken = "/persistent/crow/registry-token";
in {
    imports = [ inputs.microvm.nixosModules.host ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/persistent/crow"
        ];
    };

    systemd.services.crow-ci-agent-decrypt-secrets = {
        before = [ "microvm-virtiofsd@crow-ci-agent.service" ];
        requiredBy = [ "microvm-virtiofsd@crow-ci-agent.service" ];

        unitConfig.ConditionPathExists = [
            encryptedAgentSecret
            encryptedRegistryToken
        ];

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;

            LoadCredentialEncrypted = [
                "CROW_AGENT_SECRET:${encryptedAgentSecret}"
                "CROW_REGISTRY_TOKEN:${encryptedRegistryToken}"
            ];

            StateDirectory = "secrets/crow";
        };

        script = ''
            mkdir -p /run/secrets/crow

            echo "CROW_AGENT_SECRET=$(cat "$CREDENTIALS_DIRECTORY/CROW_AGENT_SECRET")" > /run/secrets/crow/agent-secret
            printf '%s' "$(cat "$CREDENTIALS_DIRECTORY/CROW_REGISTRY_TOKEN")" > /run/secrets/crow/registry-token

            chmod 600 /run/secrets/crow/agent-secret /run/secrets/crow/registry-token
        '';
    };

    microvm.vms.crow-ci-agent = {
        config = { ... }: {
            networking.hostName = "crow-ci-agent";

            microvm = {
                hypervisor = "qemu";
                vcpu = 4;
                mem = 4 * 1024;

                registerWithMachined = true;

                interfaces = [{
                    type = "user";
                    id = "crow-agent0";
                    mac = "02:00:00:00:02:01";
                }];

                forwardPorts = lib.optional enableSsh {
                    from = "host";
                    host.port = 2222;
                    guest.port = 22;
                };

                shares = [
                    {
                        proto = "virtiofs";
                        tag = "ro-store";
                        source = "/nix/store";
                        mountPoint = "/nix/.ro-store";
                    }
                    {
                        proto = "virtiofs";
                        tag = "crow-secrets";
                        source = "/run/secrets/crow";
                        mountPoint = "/run/secrets/crow";
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

            users.users.root.initialPassword = lib.mkIf enableSsh "crow";

            services.journald = {
                storage = "volatile";
                extraConfig = "MaxRetentionSec=3day";
            };

            systemd.tmpfiles.rules = [
                "d /var/lib/crow 0755 root root"
            ];

            virtualisation.docker = {
                enable = true;
                autoPrune.enable = true;
            };

            virtualisation.oci-containers = {
                backend = "docker";

                containers.crow-ci-agent = {
                    image = "codefloe.com/crowci/crow-agent:v6";
                    autoStart = true;

                    login = {
                        registry = "codefloe.com";
                        username = "krypt0nn";
                        passwordFile = "/run/secrets/crow/registry-token";
                    };

                    environment = {
                        DOCKER_CLIENT_TIMEOUT = "300";
                        COMPOSE_HTTP_TIMEOUT = "300";
                        CROW_SERVER = "grpc.ci.dawn.wine:443";
                        CROW_GRPC_SECURE = "true";
                        CROW_MAX_WORKFLOWS = "2";
                        CROW_BACKEND = "docker";
                        CROW_BACKEND_DOCKER_LIMIT_MEM = "4G";
                        CROW_BACKEND_DOCKER_LIMIT_CPU_QUOTA = "350000";
                        CROW_AGENT_LABELS = lib.mkIf orgOnlyAccess "org=dawn-winery";
                    };

                    environmentFiles = [
                        "/run/secrets/crow/agent-secret"
                    ];

                    volumes = [
                        "/var/run/docker.sock:/var/run/docker.sock"
                        "/var/lib/crow:/etc/crow"
                    ];

                    pull = "always";
                };
            };

            system.stateVersion = "24.05";
        };
    };

    microvm.autostart = [ "crow-ci-agent" ];
}
