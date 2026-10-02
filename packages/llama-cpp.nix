{ username, pkgs, pkgs-unstable, ... }:
let
    llama-cpp-wrapped = pkgs.symlinkJoin {
        name = "llama-cpp";
        paths = [ pkgs-unstable.llama-cpp-vulkan ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
            wrapProgram "$out/bin/llama-server" \
                --add-flags "--port 9931" \
                --add-flags "--models-dir" \
                --add-flags "/home/${username}/Models" \
                --add-flags "--models-preset" \
                --add-flags "/home/${username}/Models/models.ini" \
                --add-flags "--slot-save-path" \
                --add-flags "/home/${username}/Models/kv-cache" \
                --add-flags "--parallel 1" \
                --add-flags "--kv-unified" \
                --add-flags "--cache-type-k q8_0" \
                --add-flags "--cache-type-v q8_0" \
                --add-flags "--spec-draft-type-k q8_0" \
                --add-flags "--spec-draft-type-v q8_0" \
                --add-flags "--fit on" \
                --add-flags "--embeddings"
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
