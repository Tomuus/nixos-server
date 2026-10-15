{
  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    settings.Peers = [
      "tls://waw01.yggdrasil.hosted-by.skhron.eu:8884?key=030602cee88a761c68f5f14e1dad430f25238a703b69dc382321a38f833035b0"
      "quic://waw01.yggdrasil.hosted-by.skhron.eu:8885?key=030602cee88a761c68f5f14e1dad430f25238a703b69dc382321a38f833035b0"
      "tls://91.98.161.68:9001?key=0e638944bfd6b277fa5e0dddbeb4444778eea8bece63a9862c661797022a8f05"
      "quic://ip4.fvm.mywire.org:443?key=000000000143db657d1d6f80b5066dd109a4cb31f7dc6cb5d56050fffb014217"
    ];
  };
}
