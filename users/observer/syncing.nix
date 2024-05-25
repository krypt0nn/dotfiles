{ ... }: {
    services = {
        syncthing = {
            enable = true;

            dataDir = "/home/observer/.syncthing";
            configDir = "/home/observer/.syncthing/.config";

            overrideDevices = true;
            overrideFolders = true;

            settings = {
                devices = {
                    "observer-pc" = { id = "5HW7DWE-44ZING4-ZS4BTNF-264HIR6-3CMIKJJ-34G4RE6-V62OSLM-CJGOEAV"; };
                    # "observer-laptop" = { id = "DEVICE-ID-GOES-HERE"; };
                };

                folders = {
                    documents = {
                        path = "/home/observer/Documents";
                        devices = [ "observer-pc" ]; # "observer-laptop"
                    };

                    projects = {
                        path = "/home/observer/projects";
                        devices = [ "observer-pc" ]; # "observer-laptop"
                    };
                };
            };
        };
    };
}
