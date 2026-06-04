{ username, pkgs, pkgs-unstable, ... }:
    let
        llama-cpp-wrapped = pkgs.symlinkJoin {
            name = "llama-cpp";
            paths = [ pkgs-unstable.llama-cpp-vulkan ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
                wrapProgram "$out/bin/llama-server" \
                    --add-flags "--port 9020" \
                    --add-flags "--models-dir" \
                    --add-flags "/home/${username}/Models" \
                    --add-flags "--alias default" \
                    --add-flags "--parallel 1" \
                    --add-flags "--ctx-size 16384" \
                    --add-flags "--cache-type-k q8_0" \
                    --add-flags "--cache-type-v q8_0" \
                    --add-flags "--spec-draft-type-k q8_0" \
                    --add-flags "--spec-draft-type-v q8_0" \
                    --add-flags "--top-p 0.95" \
                    --add-flags "--top-k 20" \
                    --add-flags "--min-p 0.0" \
                    --add-flags "--presence-penalty 0.0" \
                    --add-flags "--repeat-penalty 1.0" \
                    --add-flags "--fit on" \
                    --add-flags "--no-mmap" \
                    --add-flags "--no-mmproj" \
                    --add-flags "--reasoning on" \
                    --add-flags "--tools read_file,file_glob_search,grep_search"
            '';
        };
    in {
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
