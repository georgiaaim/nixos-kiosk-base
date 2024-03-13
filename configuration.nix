{ config, pkgs, lib, ... }:
{
  # Bootloader configuration for systemd-boot (UEFI systems)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # System-wide configurations
  networking.hostName = "kiosk_base";
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  system.stateVersion = "23.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Desktop Environment and Display Manager
  #services.xserver.enable = true;
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma6.enable = true;

  services.cage = {
    enable = true;
    program = "firefox --kiosk http://localhost:8123";
    user = "kiosk";
  }

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

