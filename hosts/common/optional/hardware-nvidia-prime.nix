{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    # MX110 / GM108 — Maxwell: открытые модули НЕ поддерживаются.
    open = false;

    # Fine-grained power management только для Turing+,
    # на Maxwell оставляем выключенным.
    powerManagement.enable = false;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.switcherooControl.enable = true;
}
