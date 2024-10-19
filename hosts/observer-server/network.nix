{ ... }: {
    networking.proxy = {
        httpsProxy = "https://127.0.0.1:10050";
        noProxy = "127.0.0.1,::1,localhost,.localdomain";
    };
}
