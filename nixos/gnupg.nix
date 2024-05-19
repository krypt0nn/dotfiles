{ lib, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        gnupg
        gnupg1compat
    ];

    programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
    };
}
