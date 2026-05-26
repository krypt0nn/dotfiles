{ pkgs, ... }: {
    # My meshtastic node is connected directly to my server, so I use
    # this service to bridge my local network (and tailnet!) with
    # meshtastic.
    systemd.services.meshtastic-serial-bridge = {
        description = "Meshtastic Serial-to-TCP Bridge";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:4403,fork,reuseaddr FILE:/dev/ttyUSB0,raw,echo=0,b115200";
            Restart = "always";
            RestartSec = 5;
            User = "root";
        };
    };

    networking.firewall.allowedTCPPorts = [ 4403 ];
}
