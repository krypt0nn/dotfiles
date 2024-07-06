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
                "observer-pc"     = { id = "ANN4CJX-BOC36L6-72EYUZP-6B3J3LB-LYTF3PN-YL2JMYX-7U5BQMO-4V766A3"; };
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
