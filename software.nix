{pkgs, config, ...}: 
let
  home-assistant-qcow2 = pkgs.fetchurl {
    name = "home-assistant.qcow2";
    url = "https://github.com/home-assistant/operating-system/releases/download/12.1/haos_ova-12.1.qcow2.xz";
    sha256 = "SIcYHisZieaKpZDqXGJc7pUM8c1E1EpVtnjSlvapS2g=";
    postFetch = ''
      cp $out src.xz
      ${pkgs.xz}/bin/unxz src.xz --stdout > $out
    '';
  };
  
  virtInstallScript = pkgs.writeShellScriptBin "virt-install-hass" ''
    # Check if network is running
    ${pkgs.libvirt}/bin/virsh net-list | grep -q default || \
      ${pkgs.libvirt}/bin/virsh net-start default
    # Check if VM already exists, and other pre-conditions
    if ! ${pkgs.libvirt}/bin/virsh list --all | grep -q hass; then
      ${pkgs.virt-manager}/bin/virt-install --name hass --description "Home Assistant OS" --os-variant=generic --ram=2048 --vcpus=2 --disk /etc/home-assistant.qcow2,bus=sata --import --graphics none --boot uefi
      ${pkgs.libvirt}/bin/virsh autostart hass
    fi
  '';
in
{
  services.kioskAdmin.enable = true;

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
    libvirtd = {
      enable = true;
      nss.enable = true;
      qemu.ovmf.enable = true;
      allowedBridges = [ "virbr0" ];
    };
    docker.enable = true;
    oci-containers = {
      backend = "docker";
      containers = {
        unifi = {
          image = "jacobalberty/unifi:latest";
          ports = [ 
            "8080:8080/tcp"
            "8443:8443/tcp"
            "10.0.0.1:3478:3478/udp"
          ];
          volumes = [ "/etc/unifi:/unifi" ];
        };
      };
    };
  };

  system.activationScripts.hass-qcow2 = {
    text = ''
      if [ ! -f /etc/home-assistant.qcow2 ]; then
        cp ${home-assistant-qcow2} /etc/home-assistant.qcow2
      fi
    '';
  };

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

  #systemd.services.home-assistant = {
  #  enable = true;
  #  description = "Home Assistant";
  #  wantedBy = [ "multi-user.target" ];
  #  after = [ "local-fs.target" ];
  #  serviceConfig = {
  #    ExecStart = ''${pkgs.qemu}/bin/qemu-system-x86_64 
  #      -name hass \
  #      -m 2048 \
  #      -smp cpus=2 \
  #      -drive file=/dev/nbd0,format=raw,if=none,id=drive-sata0-0-0 \
  #      -device ahci,id=ahci \
  #      -device ide-drive,drive=drive-sata0-0-0,bus=ahci.0 \
  #      -nodefaults \
  #      -nographic \
  #      -bios /usr/share/qemu/OVMF.fd \
  #      -net nic -net user
  #    '';
  #    Restart = "always";
  #  };
  #};

  environment.systemPackages = with pkgs; [
    parted
    git
    virt-manager
    xz
    firefox
  ];

  programs.neovim.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
