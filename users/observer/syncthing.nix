{ ... }: {
    services.syncthing = {
        enable = true;
        openDefaultPorts = true;

        user = "observer";

        dataDir = "/home/observer/.syncthing";
        configDir = "/home/observer/.syncthing/.config";

        overrideDevices = true;
        overrideFolders = true;

        settings = {
            devices = {
                "observer-pc"     = { id = "J4VSRJH-7ID4NSF-C6XWJL6-U4ZLQC2-JBMADG4-QXOSACW-FYYJNEA-5WVQMAH"; };
                "observer-laptop" = { id = "JWIJBIA-6ZQUP33-GB4OEC3-KQPW3CM-YFAZDDW-LQQNPWE-DI6WYXI-XVSVKQR"; };
                "observer-server" = { id = "KBAD6RT-GHQCXW7-WYDFXF7-RKE5QOL-XSIUD6A-4E4D4G3-HLC75OZ-3ERYFQA"; };
            };

            folders = {
                documents = {
                    path = "/home/observer/Documents";

                    devices = [
                        "observer-pc"
                        "observer-laptop"
                        "observer-server"
                    ];
                };

                pictures = {
                    path = "/home/observer/Pictures";

                    devices = [
                        "observer-pc"
                        "observer-laptop"
                        "observer-server"
                    ];
                };

                videos = {
                    path = "/home/observer/Videos";

                    devices = [
                        "observer-pc"
                        "observer-laptop"
                        "observer-server"
                    ];
                };

                projects = {
                    path = "/home/observer/projects";

                    ignorePatterns = [
                        "**/target/*"
                        "**/node_modules/*"
                        "**/.direnv/*"
                        "**/.git/*"
                    ];

                    devices = [
                        "observer-pc"
                        "observer-laptop"
                        "observer-server"
                    ];
                };
            };
        };
    };
}
