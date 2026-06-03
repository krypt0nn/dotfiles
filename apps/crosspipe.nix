{ pkgs, ... }: {
    environment.systemPackages = [ pkgs.crosspipe ];
}
