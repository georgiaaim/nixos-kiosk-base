{pkgs, ...}: 
let
  # Fetch the Home Assistant OS qcow2 image
  home-assistant-qcow2 = pkgs.fetchurl {
    name = "home-assistant.qcow2";
    url = "https://github.com/home-assistant/operating-system/releases/download/13.1/haos_ova-13.1.qcow2.xz";
    sha256 = "O3okbo49vHvxmeBnzABDSH4zlcJZcJ8cmrWrZC5Jves=";
    postFetch = ''
      cp $out src.xz
      ${pkgs.xz}/bin/unxz src.xz --stdout > $out
    '';
  };
  
  # Write a script to install the Home Assistant OS qcow2 image
  virtInstallScript = pkgs.writeShellScriptBin "virt-install-hass" ''
    # Check if VM already exists, and other pre-conditions
    if ! ${pkgs.libvirt}/bin/virsh list --all | grep -q hass; then
      ${pkgs.virt-manager}/bin/virt-install --name hass --network bridge=br0 --description "Home Assistant OS" --os-variant=generic --ram=2048 --vcpus=2 --disk /etc/home-assistant.qcow2,bus=sata --import --graphics none --boot uefi
      ${pkgs.libvirt}/bin/virsh autostart hass
    fi
  '';
in
{
  # Ensure the Unifi directories exist
  system.activationScripts.create-unifi-dir = {
    text = ''
      if [ ! -d /etc/unifi ]; then
        mkdir /etc/unifi
        mkdir /etc/unifi/data
        mkdir /etc/unifi/logs
        chown -R root:root /etc/unifi
      fi
    '';
  };

  virtualisation = {
    # Enable libvirtd and Docker 
    libvirtd = {
      enable = true;
      nss.enable = true;
      qemu.ovmf.enable = true;
      allowedBridges = [ "br0" ];
    };
    docker.enable = true;

    # Define the Docker container(s)
    oci-containers = {
      backend = "docker";
      containers = {
        # Unifi Controller Docker Container
        unifi = {
          image = "jacobalberty/unifi:latest";
          extraOptions = [ "--net=host" ];
          volumes = [ "/etc/unifi:/unifi" ];
        };
      };
    };
  };

  # Ensure the Home Assistant OS qcow2 image is available in a writable location
  system.activationScripts.hass-qcow2 = {
    text = ''
      if [ ! -f /etc/home-assistant.qcow2 ]; then
        cp ${home-assistant-qcow2} /etc/home-assistant.qcow2
      fi
    '';
  };

  # Define the Home Assistant OS installation service
  systemd.services.virt-install-hass = {
    enable = true;
    description = "Home Assistant";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    unitConfig = {
      Type = "oneshot";
      Requires = [ "libvirtd.service" ];
    };
    serviceConfig = {
      ExecStart = "${virtInstallScript}/bin/virt-install-hass";
    };
  };

  # programs.dconf.enable = true;

  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
  };

  services.displayManager = {
    enable = true;
    sddm = {
      enable = true;
      settings = {
        Autologin = {
          User = "kiosk";
          Relogin = true;
        };
      };
    };
  };

    # Extra software packages to install
  environment.systemPackages = with pkgs; [
    # gnome.gnome-tweaks
    wmctrl
    parted
    git
    git-lfs
    virt-manager
    xz
    firefox
  ];
  
  nixpkgs.overlays = [
    (final: prev: {
      cloud-hypervisor = null;
    })
  ];

  programs.git.enable = true;
  programs.git.lfs.enable = true;

  # Enable the Neovim and Zsh programs
  programs.neovim.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
