{ username, pkgs-unstable, ... }:
    let
        config = ''
            window-width = 90
            window-height = 26
        '';
    in {
        environment.systemPackages = [ pkgs-unstable.ghostty ];

        systemd.tmpfiles.rules = [
            "d /home/${username}/.config/ghostty 0755 ${username} users -"
            "F /home/${username}/.config/ghostty/config 0644 ${username} users - ${config}"
        ];
    }
