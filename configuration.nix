{ config, pkgs, lib, ... }:
{

  # Bootloader configuration for systemd-boot (UEFI systems)
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.initrd.verbose = false;
  boot.initrd.systemd.enable = true;

  boot.loader.grub = {
    enable = true;
    device = "nodev"; # for EFI systems, set to your specific device, or use "nodev" for UEFI-only systems
    efiSupport = true;
    splashImage = ./ga-aim-logo-final-white.tga;
    configurationLimit = 3;
  };
  
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  }; 

  boot.kernelParams = [ "quiet" "rd.systemd.show_status=false"]; # Ensure a quiet boot
  boot.consoleLogLevel = 0;

  boot.plymouth.enable = true;

  #networking = {
  #  useDHCP = false;
  #  interfaces = {
  #    enp2s0 = {
  #      useDHCP = true;
  #    };
  #    enp3s0 = {
  #      useDHCP = false;
  #      addresses = [ {
  #        address = "10.0.0.1";
  #        prefixLength = 24;
  #      } ];
  #    };
  #  };
  #};

  systemd.network.enable = true;
  systemd.network.networks = {
    enp2s0 = {
      enable = true;
      dhcp4 = true;
    };
    enp3s0 = {
      networkConfig = {
        Address = "10.0.0.1/24";
        DHCPServer = true;
        IPMasquerade="ipv4";
      };
      dhcpServerConfig = {
        EmitDNS = false;
      };
      enable = true;
      dhcp4 = false;
    };
  };

  #networking.defaultGateway = "10.0.0.1";
  #networking.bridges.br0.interfaces = [ "enp2s0" ];
  #networking.interfaces.br0 = {
  #  ipv4.addresses = [ { address = "10.0.0.5"; prefixLength = 24; } ];
  #};

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  system.stateVersion = "23.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.xserver.windowManager.xmonad.enable = true;

  # Desktop Environment and Display Manager
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland.enable = true;
  services.xserver.displayManager.job.preStart = "sleep 1";

  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "kiosk";
  };

  services.desktopManager.plasma6.enable = true;

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

