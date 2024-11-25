final: prev: {
  # Hacky force Wayland
  signal-desktop = prev.signal-desktop.overrideAttrs (oldAttrs: {
    meta.platforms = ["x86_64-linux" "aarch64-linux"];
    postInstall = ''
      substituteInPlace $out/share/applications/signal-desktop.desktop \
        --replace '--no-sandbox' '--no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland'
    '';
  });

  logseq = prev.logseq.overrideAttrs (oldAttrs: {
    meta.platforms = ["x86_64-linux" "aarch64-linux"];
    postInstall = ''
      substituteInPlace $out/share/applications/logseq.desktop \
        --replace 'Exec=logseq' 'Exec=logseq --enable-features=UseOzonePlatform --ozone-platform=wayland'
    '';
  });
}
