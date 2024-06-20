{ ... }: {
    programs.virt-manager.enable = true;

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/var/lib/libvirt"
        ];
    };
}
