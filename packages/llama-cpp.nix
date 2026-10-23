{ username, pkgs, pkgs-unstable, ... }:
let
    llama-cpp-wrapped = pkgs.symlinkJoin {
        name = "llama-cpp";
        paths = [ pkgs-unstable.llama-cpp-vulkan ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
            wrapProgram "$out/bin/llama-server" \
                --add-flags "--port 9931" \
                --add-flags "--models-preset" \
                --add-flags "/home/${username}/Models/models.ini" \
                --add-flags "--slot-save-path" \
                --add-flags "/home/${username}/Models/kv-cache" \
                --add-flags "--cache-type-k bf16" \
                --add-flags "--cache-type-v bf16" \
                --add-flags "--spec-draft-type-k bf16" \
                --add-flags "--spec-draft-type-v bf16" \
                --add-flags "--parallel 1"
        '';
    };
in {
    networking.firewall.allowedTCPPorts = [ 9931 ];

    environment.systemPackages = [
        llama-cpp-wrapped
    ];

    environment.persistence."/persistent" = {
        hideMounts = true;

        users.${username}.directories = [
            "Models"
        ];
    };
}
