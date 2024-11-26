{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.khome.hardware.amdgpu;
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    optional
    optionals
    ;
in
{
  options.khome.hardware.amdgpu = {
    enable = mkEnableOption "enable amdgpu";
    headless = mkEnableOption "headless only amdgpu";
    addTools = mkEnableOption "add rocm/amd tools to system packages" // {
      default = true;
    };
    opencl = mkEnableOption "enable opencl" // {
      default = true;
    };
    vulkan = mkEnableOption "enable amd vulkan" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    provision.security.wrappers = mkIf cfg.addTools {
      amdgpu_top.elewrap = {
        enable = true;
        allowedGroups = [
          "video"
          "adm"
        ];
      };
    };
    boot.initrd.kernelModules = [ "amdgpu" ];
    environment.systemPackages =
      with pkgs;
      mkIf cfg.addTools [
        rocmPackages.rocm-smi
        lact
        radeontop
        radeon-profile
        nvtopPackages.amd
      ];
    hardware = {
      # You nearly always need this when using a GPU, even with `amdgpu` and `i915`
      enableRedistributableFirmware = mkDefault true;
      amdgpu = {
        initrd.enable = !cfg.headless;
        opencl.enable = cfg.opencl;
        amdvlk = {
          enable = cfg.vulkan;
          support32Bit.enable = true;
        };
      };
    };
    # systemd.tmpfiles.rules = [
    #   "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
    # ];
  };
}
