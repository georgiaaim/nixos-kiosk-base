{ config, pkgs, lib, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  environment.systemPackages = [
    pkgs.adi1090x-plymouth-themes
  ];

  # Bootloader configuration for systemd-boot (UEFI systems)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev"; # for EFI systems, set to your specific device, or use "nodev" for UEFI-only systems
    efiSupport = true;
    splashImage = "./ga-aim-logo-final-white.tga";
    timeout = 0; # Set timeout to 0 for an immediate boot
    extraConfig = ''
    # Custom GRUB configurations for a silent boot
    set quiet=1
    '';
  };

  # Enable Plymouth for a custom boot screen
  services.plymouth.enable = true;
  services.plymouth.theme = "circle"; # Use your desired theme
  boot.kernelParams = [ "splash" "quiet" ]; # Ensure a quiet boot

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
  services.xserver.displayManager.sddm.autoLogin.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;
  services.xserver.displayManager.sddm.autoLogin.user = "kiosk";

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

