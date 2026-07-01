{ inputs, lib, ... }:
let
    enableSSH = false;
    encryptedSecret = "/persistent/crow/agent-secret";
in {
    imports = [ inputs.microvm.nixosModules.host ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/persistent/crow"
        ];
    };

    systemd.services.crow-ci-agent-decrypt-secret = {
        before = [ "microvm-virtiofsd@crow-ci-agent.service" ];
        requiredBy = [ "microvm-virtiofsd@crow-ci-agent.service" ];

        unitConfig.ConditionPathExists = encryptedSecret;

        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            LoadCredentialEncrypted = "CROW_AGENT_SECRET:${encryptedSecret}";
            StateDirectory = "secrets/crow";
        };

        script = ''
            echo "CROW_AGENT_SECRET=$(cat "$CREDENTIALS_DIRECTORY/CROW_AGENT_SECRET")" > /run/secrets/crow/agent-secret
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

                forwardPorts = lib.optional enableSSH {
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

            services.openssh = lib.mkIf enableSSH {
                enable = true;
                settings.PermitRootLogin = "yes";
                settings.PasswordAuthentication = true;
            };

            users.users.root.initialPassword = lib.mkIf enableSSH "crow";

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
                    image = "codefloe.com/crowci/crow-agent:v5";
                    autoStart = true;

                    environment = {
                        CROW_SERVER = "grpc.ci.dawn.wine";
                        CROW_GRPC_SECURE = "true";
                        CROW_MAX_WORKFLOWS = "2";
                        CROW_BACKEND = "docker";
                        CROW_BACKEND_DOCKER_LIMIT_MEM = "4.3G";
                        CROW_BACKEND_DOCKER_LIMIT_CPU_QUOTA = "350000";
                        # CROW_AGENT_LABELS = "org=dawn-winery";
                    };

                    environmentFiles = [
                        "/run/secrets/crow/agent-secret"
                    ];

                    volumes = [
                        "/var/run/docker.sock:/var/run/docker.sock"
                        "/var/lib/crow:/etc/crow"
                    ];

                    extraOptions = [ "--pull=always" ];
                };
            };

            system.stateVersion = "24.05";
        };
    };

    microvm.autostart = [ "crow-ci-agent" ];
}
