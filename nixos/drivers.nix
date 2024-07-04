{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        (ffmpeg-full.override {
            withUnfree = true;
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

            # This should fix some wine games not being able
            # to lookup GPU drivers via DXVK
            vulkan-loader
            vulkan-validation-layers
            vulkan-extension-layer
        ];

        extraPackages32 = with pkgs.pkgsi686Linux; [
            libva
            vaapiVdpau
            libvdpau-va-gl
        ];
    };

    # Workaround for HIP drivers on NixOS
    systemd.tmpfiles.rules = [
        "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];
}
