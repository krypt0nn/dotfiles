{ ... }: {
    hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;

        settings.General = {
            Experimental = true;
            KernelExperimental = true;
        };
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/var/lib/bluetooth"
        ];
    };
}
