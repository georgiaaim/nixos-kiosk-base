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
    # Check if VM already exists, and other pre-conditions
    ${pkgs.libvirt}/bin/virsh net-start default
    if ! ${pkgs.libvirt}/bin/virsh list --all | grep -q hass; then
      ${pkgs.virt-manager}/bin/virt-install --name hass --description "Home Assistant OS" --os-variant=generic --ram=2048 --vcpus=2 --disk /etc/home-assistant.qcow2,bus=sata --import --graphics none --boot uefi
    else
      ${pkgs.libvirt}/bin/virsh start hass
    fi
  '';
in
{
  services.kioskAdmin.enable = true;
  
  virtualisation = {
    libvirtd = {
      enable = true;
      nss.enable = true;
      qemu.ovmf.enable = true;
      allowedBridges = [ "virbr0" ];
    };
  };

  system.activationScripts.hass-qcow2 = {
    text = ''
      if [ ! -f /etc/home-assistant.qcow2 ]; then
        cp ${home-assistant-qcow2} /etc/home-assistant.qcow2
      fi
    '';
  };

  system.activationScripts.virt-install-hass = {
    text = "${virtInstallScript}/bin/virt-install-hass";
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
