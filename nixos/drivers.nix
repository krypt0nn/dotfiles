{ pkgs, ... }: {
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
            vaapiVdpau
            libvdpau-va-gl
        ];
    };
}
