{ lib, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        gnupg
        gnupg1compat
    ];

    programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
    };

    environment.variables.SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
}
