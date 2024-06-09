{ ... }: {
    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/system-flake"
            "/var/log"
            "/var/lib/bluetooth"
            "/var/lib/nixos"
            "/var/lib/systemd/coredump"
            "/etc/NetworkManager/system-connections"
            { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
        ];

        files = [
            "/etc/machine-id"
            "/etc/adjtime"
            "/etc/NIXOS"

            "/etc/shadow"
            "/etc/passwd"
            "/etc/sudoers"
            "/etc/group"

            { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
        ];
    };
}
