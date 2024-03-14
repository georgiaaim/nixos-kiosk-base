{pkgs, ...}: 
let
  home-assistant-qcow2 = pkgs.fetchurl {
    name = "home-assistant.qcow2";
    url = "https://github.com/home-assistant/operating-system/releases/download/12.1/haos_ova-12.1.qcow2.xz";
    sha256 = "1rrhrzp5y219phd4iwj2ak2fvnrxdgjx7lszkp7pll97104fybff";
    postFetch = ''
      cp $out src.xz
      ${pkgs.xz}/bin/unxz src.xz --stdout > $out
    '';
  }
in
{
  services.kioskAdmin.enable = true;
  # Mount the qcow2 to /etc/homeassistant
  systemd.services.mount-home-assistant-qcow2 = {
    description = "Mount Home Assistant qcow2";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = ''
        if [ ! -f /etc/home-assistant.qcow2 ]; then
          cp ${home-assistant-qcow2} /etc/home-assistant.qcow2
        fi
      '';
      ExecStart = "${pkgs.qemu}/bin/qemu-nbd --connect=/dev/nbd0 /etc/home-assistant.qcow2";
      ExecStartPost = "mount /dev/nbd0p1 /etc/homeassistant";
      ExecStop = ''
        umount /etc/homeassistant";
        ExecStop = "${pkgs.qemu}/bin/qemu-nbd --disconnect /dev/nbd0
      '';
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
