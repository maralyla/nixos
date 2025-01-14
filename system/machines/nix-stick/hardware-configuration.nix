{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e2805613-f0a0-46ce-b419-33a32da7ca03";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."stick-root".device = "/dev/disk/by-uuid/258f07da-ff42-4df7-a573-e4c21ace1afd";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9485-0DA5";
    fsType = "vfat";
  };

  fileSystems."/stick-fat" = {
    device = "/dev/disk/by-uuid/122A-BAF6";
    fsType = "vfat";
  };

  swapDevices = [];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;
}
