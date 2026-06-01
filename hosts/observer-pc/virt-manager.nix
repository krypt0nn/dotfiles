{ lib, ... }: {
    programs.virt-manager.enable = true;

    systemd.tmpfiles.rules = [
        "d /var/lib/libvirt/secrets 0750 root root -"
    ];

    systemd.services.libvirtd.serviceConfig.LoadCredentialEncrypted = lib.mkForce "";

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/var/lib/libvirt"
        ];
    };
}
