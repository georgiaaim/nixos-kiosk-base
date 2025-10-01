{config, lib, pkgs,  ...}:

let
  kioskAdminHunterSSHKeys = builtins.fetchurl {
    url = "https://github.com/jyumpp.keys";
    sha256 = "1axvz83ks2kpc06ahc5qp3b89ga308nmaqwd17nril2kjp8k4y8f";
  };

  kioskAdminMarcusSSHKeys = builtins.fetchurl {
    url = "https://github.com/mardawgster.keys";
    sha256 = "0mdqa9w1p6cmli6976v4wi0sw9r4p5prkj7lzfd1877wk11c9c73";
  };

  allSSHKeys = builtins.readFile kioskAdminHunterSSHKeys + "\n" + 
               builtins.readFile kioskAdminMarcusSSHKeys;

  sshKeys = builtins.filter (s: s != "") (lib.splitString "\n" allSSHKeys);
in
{
  users.users = {
    kioskadmin = {
      createHome = true;
      extraGroups = ["wheel" "sudo" "libvirt"];
      group = "users";
      home = "/home/kioskadmin";
      shell = "/run/current-system/sw/bin/zsh";
      uid = 1001;
      isNormalUser = true;
      hashedPassword = "$y$j9T$5fxR9An0pF.rgp07lLJxY1$1T5TkKiVEE7scgxhy00D50zaGGJuarElu.U4X7nX9q7";
      openssh.authorizedKeys.keys = sshKeys;
    };

    kiosk = {
      createHome = true;
      extraGroups = ["wheel" "nopasswdlogin"];
      group = "users";
      home = "/home/kiosk";
      shell = "/run/current-system/sw/bin/zsh";
      uid = 1000;
      isNormalUser = true;
      hashedPassword = "";
    };
  };

  security.pam.services.gdm.enableGnomeKeyring = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.kioskadmin = import ./kioskadmin-home.nix;
  home-manager.users.kiosk = import ./kiosk-home.nix;
}
