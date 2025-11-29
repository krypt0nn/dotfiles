{ lib, ... }: {
    home = {
        username = "observer";
        homeDirectory = "/home/observer";
    };

    programs = {
        git = {
            enable = true;

            settings = {
                user = {
                    name = "Nikita Podvirnyi";
                    email = "krypt0nn@vk.com";
                };

                signing = {
                    signByDefault = true;
                    key = "3B14311A878F6C8817482002859D416E5142AFF3";
                };

                safe.directory = "/system-flake";
            };
        };
    };

    # Set keyboard languages
    dconf.settings = {
        "org/gnome/desktop/input-sources" = {
            show-all-sources = true;

            sources = with lib.hm.gvariant; [
                (mkTuple [ "xkb" "us" ])
                (mkTuple [ "xkb" "ru" ])
            ];
        };
    };
}
