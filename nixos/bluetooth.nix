{...}: {
    hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;

        settings.General = {
            Experimental = true;
            KernelExperimental = true;
        };
    };

    services.blueman.enable = true;
}
