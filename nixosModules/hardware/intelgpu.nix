{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.hardware.intelgpu;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.khome.hardware.intelgpu = {
    enable = mkEnableOption "enable intelgpu integrations";
  };

  config = mkIf cfg.enable {
    boot.initrd.kernelModules = [ "i915" ];
    services.xserver.videoDrivers = [ "intel" ];
    environment.systemPackages = with pkgs; [
      libva-utils
      nvtopPackages.intel
    ];
    hardware = {
      # You nearly always need this when using a GPU, even with `amdgpu` and `i915`
      enableRedistributableFirmware = lib.mkDefault true;
      # intel-gpu-tools.enable = true;
      # intelgpu = {
      #   loadInInitrd = true;
      # };
      graphics = {
        enable = true;
        # OpenCL
        extraPackages = with pkgs; [
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          #vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
          vaapiVdpau
          libvdpau-va-gl
        ];
        enable32Bit = true;
        extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];
      };
    };
  };
}
