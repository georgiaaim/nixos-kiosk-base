{ config, pkgs, lib, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader configuration for systemd-boot (UEFI systems)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.initrd.verbose = false;

  boot.plymouth.enable = true;

  #boot.loader.grub = {
  #  enable = true;
  #  device = "nodev"; # for EFI systems, set to your specific device, or use "nodev" for UEFI-only systems
  #  efiSupport = true;
  #  splashImage = ./ga-aim-logo-final-white.tga;
  #  configurationLimit = 3;
  #};

  boot.kernelParams = [ "splash" "quiet" "rd.systemd.show_status=false"]; # Ensure a quiet boot
  consoleLogLevel = 0;

  # System-wide configurations
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  system.stateVersion = "23.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Desktop Environment and Display Manager
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland.enable = true;

  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "kiosk";

  services.xserver.desktopManager.plasma6.enable = true;

  # Enable CUPS for printing
  services.printing.enable = true;

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}

