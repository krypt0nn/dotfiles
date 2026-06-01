{ pkgs, ... }:
    let
        # FIXME: cannot use GPU...
        bottles-wrapped = pkgs.bottles.override {
            removeWarningPopup = true;

            buildFHSEnv = pkgs.mkBwrapperFHSEnv {
                imports = [ pkgs.bwrapperPresets.desktop ];

                app = {
                    id = "com.usebottles.bottles";
                    package-unwrapped = pkgs.bottles-unwrapped;
                };

                dbus = {
                    system.talks = [ "org.freedesktop.UDisks2" ];
                    session.owns = [ "com.usebottles.bottles" ];
                };

                mounts.readWrite = [
                    "$HOME/.local/share/bottles"
                ];
            };
        };
    in {
        environment.systemPackages = [
            # bottles-wrapped
            pkgs.bottles
        ];

        environment.persistence."/persistent" = {
            hideMounts = true;

            users.observer = {
                directories = [
                    ".local/share/bottles"
                ];
            };
        };
    }
