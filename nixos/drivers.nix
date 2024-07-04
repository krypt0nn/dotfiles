{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        (ffmpeg-full.override {
            withUnfree = true;
            withOpenGL = true;
        })
    ];

    hardware.opengl = {
        enable = true;
    
        driSupport = true;
        driSupport32Bit = true;

        extraPackages = with pkgs; [
            rocmPackages.clr.icd
            libva
            vaapiVdpau
            libvdpau-va-gl
        ];

        extraPackages32 = with pkgs.pkgsi686Linux; [
            libva
            vaapiVdpau
            libvdpau-va-gl
        ];
    };
}
