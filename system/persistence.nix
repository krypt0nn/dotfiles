{ ... }: {
    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/system-flake"
            "/var/tmp"
            "/var/log"
            "/var/lib/nixos"
            "/var/lib/systemd"
            "/var/lib/NetworkManager"
            "/var/lib/microvms"
            "/var/db/sudo"
            "/etc/ssh"
            "/etc/NetworkManager/system-connections"
            { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
        ];

        files = [
            "/etc/machine-id"
            "/etc/adjtime"

            { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
        ];
    };
}
