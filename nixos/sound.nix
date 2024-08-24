{ lib, ... }: {
    sound.enable = true;

    services.pipewire = {
        enable = true;

        jack.enable = true;
        pulse.enable = true;

        alsa = {
            enable = true;
            support32Bit = true;
        };
    };

    hardware.pulseaudio.enable = lib.mkForce false;
}
