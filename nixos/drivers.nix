{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        (ffmpeg-full.override {
            withUnfree = true;
        })

        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
        gst_all_1.gst-vaapi
    ];

    hardware.firmware = [
        pkgs.linux-firmware
    ];

    hardware.graphics = {
        enable = true;
        enable32Bit = true;

        extraPackages = with pkgs; [
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
}
