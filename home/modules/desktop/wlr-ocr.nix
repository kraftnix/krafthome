localFlake:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.wl-ocr;
  inherit (lib)
    getExe
    mkIf
    mkOption
    types
    ;

  # use OCR and copy to clipboard
  ocrScript =
    let
      inherit (pkgs)
        grim
        libnotify
        slurp
        tesseract5
        wl-clipboard
        ;
    in
    pkgs.writeShellScriptBin "wl-ocr" ''
      ${getExe grim} -g "$(${getExe slurp})" -t ppm - | ${getExe tesseract5} - - | ${wl-clipboard}/bin/wl-copy
      ${getExe libnotify} "$(${wl-clipboard}/bin/wl-paste)"
    '';
in
{
  options.programs.wl-ocr = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable wl-ocr script.";
    };

    keybind = mkOption {
      type = types.str;
      default = "o";
      description = "keybind with (mod + shift)";
    };

    ocrScript = mkOption {
      type = types.pathInStore;
      default = ocrScript;
      description = "ocr script";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.ocrScript ];

    khome.desktop.wm.shared.binds.wlr-ocr = mkIf (cfg.keybind != "") {
      exec = true;
      mapping = cfg.keybind;
      command = "${cfg.ocrScript}/bin/wl-ocr";
      extraKeys = [ "Shift" ];
      niri.output.hotkey-overlay.title = "OCR text into clipboard from a selected area.";
    };

  };
}
