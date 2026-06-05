{ username, pkgs-unstable, ... }:
    let
        config = ''
            window-width = 90
            window-height = 26
        '';
    in {
        environment.systemPackages = [ pkgs-unstable.ghostty ];

        # The default value from ghostty is "xterm-ghostty" and, who would have
        # guessed, it's absolutely not supported by anything.
        programs.bash.interactiveShellInit = "export TERM=xterm-256color";
        programs.fish.interactiveShellInit = "set -gx TERM xterm-256color";

        systemd.tmpfiles.rules = [
            "d /home/${username}/.config/ghostty 0755 ${username} users -"
            "F /home/${username}/.config/ghostty/config 0644 ${username} users - ${config}"
        ];
    }
