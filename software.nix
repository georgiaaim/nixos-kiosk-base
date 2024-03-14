{pkgs, ...}: 
let
  home-assistant-qcow2 = pkgs.fetchurl {
    name = `home-assistant.qcow2`;
    url = "https://github.com/home-assistant/operating-system/releases/download/12.1/haos_ova-12.1.qcow2.xz";
    sha256 = pkgs.lib.fakeSha256;
    postFetch = ''
      cp $out src.xz
      ${pkgs.xz}/bin/unxz src.xz --stdout > $out
    '';
  }
in
{
  services.kioskAdmin.enable = true;

  environment.systemPackages = with pkgs; [
    parted
    unxz
    firefox
  ];

  programs.neovim.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
