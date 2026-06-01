{ pkgs-unstable, ... }:
    let
        config = ''
            window-width = 90
            window-height = 26
        '';
    in {
        environment.systemPackages = [ pkgs-unstable.ghostty ];

        systemd.tmpfiles.rules = [
            "d /home/observer/.config/ghostty 0755 observer users -"
            "F /home/observer/.config/ghostty/config 0644 observer users - ${config}"
        ];
    }
