{inputs, ...}: {
  imports = [
    ./flakeModules/vim-plugins.nix
    ./shells.nix
    #./flakeModules/lib-module.nix
    ./lib
  ];
}
