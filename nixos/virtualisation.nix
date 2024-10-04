{ pkgs, ... }: {
    boot.kernelModules = [ "kvm-amd" ];

    virtualisation.virtualbox.host.enable = true;
    users.extraGroups.vboxusers.members = [ "observer" ];

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
}
