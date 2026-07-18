{ username, lib, pkgs, ... }:
let
    enable = true;
    serverDir = "/home/${username}/Desktop/minecraft-server/statech-industries-s2";
in lib.mkIf enable {
    systemd.services.minecraft-server = {
        description = "Minecraft server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
            Type = "simple";
            User = username;
            Group = "users";
            WorkingDirectory = serverDir;

            ExecStart = lib.escapeShellArgs [
                "${pkgs.bubblewrap}/bin/bwrap"
                "--bind" serverDir serverDir
                "--chdir" serverDir
                "--ro-bind" "/nix/store" "/nix/store"
                "--ro-bind" "/usr/bin" "/usr/bin"
                "--ro-bind" "/sys" "/sys"
                "--proc" "/proc"
                "--dev" "/dev"
                "--tmpfs" "/tmp"
                "--unshare-all"
                "--share-net"
                "--ro-bind" "/etc/resolv.conf" "/etc/resolv.conf"
                "--ro-bind" "/etc/hosts" "/etc/hosts"
                "${pkgs.jdk21_headless}/bin/java"
                "-server" "-Xms8G" "-Xmx8G" "-jar" "${serverDir}/server.jar" "nogui"
            ];

            Restart = "always";
            RestartSec = "10";
        };
    };
}
