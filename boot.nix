{ config, pkgs, lib, ... }:
{
  # Bootloader configuration for systemd-boot (UEFI systems)
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.initrd.verbose = false;
  boot.initrd.systemd.enable = true;

  # Set up GRUB 2 with GA-AIM logo as splash image
  boot.loader.grub = {
    enable = true;
    device = "nodev"; # for EFI systems, set to your specific device, or use "nodev" for UEFI-only systems
    efiSupport = true;
    splashImage = ./assets/ga-aim-logo-final-white.tga;
    configurationLimit = 5;
  };
  
  # Boot silently
  boot.kernelParams = [ "quiet" "rd.systemd.show_status=false"]; # Ensure a quiet boot
  boot.consoleLogLevel = 0;

  # Boot pretty
  boot.plymouth.enable = true;
  boot.plymouth.theme = pkgs.plymouthThemes.kde;

  # Set up locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Specify Nix specific options
  system.stateVersion = "23.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable Wayland and SDDM for Plasma 6
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Immediately open kiosk user on boot
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "kiosk";
  };

  # Enable SSH for remote access
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;

  # Enable CUPS for printing
  services.printing.enable = true;

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire.enable = true;
}

