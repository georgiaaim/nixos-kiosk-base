{config, lib, pkgs,  ...}:

let
  kioskAdminHunterSSHKeys = builtins.fetchurl {
    url = "https://github.com/jyumpp.keys";
    sha256 = "1axvz83ks2kpc06ahc5qp3b89ga308nmaqwd17nril2kjp8k4y8f";
  };

  kioskAdminTomasSSHKeys = builtins.fetchurl {
    url = "https://github.com/Tomz295.keys";
    sha256 = "0m84pb0k4cxgz8dn81d3kwrxz0f6qcm59if65kmmd4574pwd9ad7";
  };

  kioskAdminMarcusSSHKeys = builtins.fetchurl {
    url = "https://github.com/mardawgster.keys";
    sha256 = "011pm4ld3h1h2zf9rzlzm8x6hqf1kg2w7rc70rkx3dm66jf5l7b3";
  };

  allSSHKeys = builtins.readFile kioskAdminHunterSSHKeys + "\n" + 
               builtins.readFile kioskAdminTomasSSHKeys + "\n" + 
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
