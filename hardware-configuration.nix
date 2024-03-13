{ config, lib, pkgs, ... }:
{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ab6548d8-ad94-4226-9bc3-0b3e2b050f9b";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0452-2162";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/8e1c0085-b940-4c77-955d-d363c393e4d3"; } ];

  networking.useDHCP = lib.mkDefault true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

