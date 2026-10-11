{ inputs, ... }: {
    environment.systemPackages = [
        inputs.hermes-agent.packages.x86_64-linux.desktop
    ];
}
