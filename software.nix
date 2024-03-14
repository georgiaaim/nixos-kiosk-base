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
in
{
  services.kioskAdmin.enable = true;
  programs.nbd.enable = true;
  # Mount the qcow2 to /etc/homeassistant
  systemd.services.mount-home-assistant-qcow2 = {
    description = "Mount Home Assistant qcow2";

    wantedBy = [ "multi-user.target" ];

    partOf = [ "local-fs.target" ];

    preStart = ''
      if [ ! -f /etc/home-assistant.qcow2 ]; then
        cp ${home-assistant-qcow2} /etc/home-assistant.qcow2
      fi
      mkdir -p /etc/homeassistant
      ${pkgs.qemu}/bin/qemu-nbd --connect=/dev/nbd0 /etc/home-assistant.qcow2
    '';

    script = "${pkgs.mount}/bin/mount /dev/nbd0p8 /etc/homeassistant";

    preStop = ''
      ${pkgs.umount}/bin/umount /etc/homeassistant
      ${pkgs.qemu}/bin/qemu-nbd --disconnect /dev/nbd0
    '';

    serviceConfig = {
      Type = "forking";
    };
  };
  
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
      allowedBridges = [ "virbr0" ];
    };
  };

  systemd.services.home-assistant = {
    enable = true;
    description = "Home Assistant";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      ExecStart = ''${pkgs.qemu}/bin/qemu-system-x86_64 
        -name hass \
        -m 2048 \
        -smp cpus=2 \
        -drive file=/dev/nbd0,format=raw,if=none,id=drive-sata0-0-0 \
        -device ahci,id=ahci \
        -device ide-drive,drive=drive-sata0-0-0,bus=ahci.0 \
        -nodefaults \
        -nographic \
        -bios /usr/share/qemu/OVMF.fd \
        -net nic -net user
      '';
      Restart = "always";
    };
  };

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
