{
  qt.enable = true;
  #qt.platformTheme = "gnome";
  #qt.style.name = "qt5ct";
  #qt.style.package = pkgs.libsForQt5.breeze-qt5;
  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = 1;
  };
  khome.themes = {
    #qt.enable = true;
    gtk.enable = true;
  };
}
