{ username, ... }: {
    boot.kernelModules = [ "kvm-amd" ];

    virtualisation = {
        containers.enable = true;
        libvirtd.enable = true;

        podman = {
            enable = true;
            dockerCompat = true;

            defaultNetwork.settings.dns_enabled = true;

            dockerSocket.enable = true;
        };
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username} = {
            directories = [
                ".local/share/containers"
            ];
        };
    };
}
