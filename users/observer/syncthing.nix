{ ... }: {
    services.syncthing = {
        enable = true;

        user = "observer";

        dataDir = "/home/observer/.syncthing";
        configDir = "/home/observer/.syncthing/.config";

        overrideDevices = true;
        overrideFolders = true;

        settings = {
            devices = {
                "observer-pc"     = { id = "4TX2PRI-LGLEIOD-UFIWU7X-W3MVXTM-QAFSX2M-IJXUYZI-4NOSWPC-7GXT4AB"; };
                "observer-laptop" = { id = "JWIJBIA-6ZQUP33-GB4OEC3-KQPW3CM-YFAZDDW-LQQNPWE-DI6WYXI-XVSVKQR"; };
            };

            folders = {
                documents = {
                    path = "/home/observer/Documents";

                    devices = [
                        "observer-pc"
                        "observer-laptop"
                    ];
                };

                projects = {
                    path = "/home/observer/projects";

                    devices = [
                        "observer-pc"
                        "observer-laptop"
                    ];
                };
            };
        };
    };
}
