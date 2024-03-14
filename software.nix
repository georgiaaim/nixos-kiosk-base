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
  boot.extraModulePackages = with config.boot.kernelPackages; [ nbd ];
  # Mount the qcow2 to /etc/homeassistant
  systemd.services.mount-home-assistant-qcow2 = {
    description = "Mount Home Assistant qcow2";

    wantedBy = [ "multi-user.target" ];

    after = [ "local-fs.target" ];

    preStart = ''
      if [ ! -f /etc/home-assistant.qcow2 ]; then
        cp ${home-assistant-qcow2} /etc/home-assistant.qcow2
      fi
      ${pkgs.qemu}/bin/qemu-nbd --connect=/dev/nbd0 /etc/home-assistant.qcow2
    '';

    script = ''
      mount /dev/nbd0p1 /etc/homeassistant
    '';

    preStop = ''
      umount /etc/homeassistant
      ${pkgs.qemu}/bin/qemu-nbd --disconnect /dev/nbd0
    '';

    serviceConfig = {
      Type = "oneshot";
    };
  };

  environment.systemPackages = with pkgs; [
    parted
    qemu
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
