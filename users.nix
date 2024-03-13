{config, lib, pkgs, nix, ...}:

let
  kioskAdminSSHKeys = builtins.fetchurl {
    url = "https://github.com/jyumpp.keys";
    sha256 = "1vw70xfra52pycw9nhssnghbnm5nbji3487a5gv7zc3gr79xpn91";
  };

  contents = builtins.replaceStrings ["\r"] [""] (builtins.readFile kioskAdminSSHKeys);
  sshKeys = builtins.filter (s: s != "") (lib.splitString "\n" contents);

in
{
  options = {
    services.kioskAdmin = {
      enable = lib.mkEnableOption "KioskAdmin user service";
    };
  };

  config = lib.mkIf config.services.kioskAdmin.enable {
    users.users = {
      kioskadmin = {
        createHome = true;
        extraGroups = ["wheel" "sudo"];
        group = "users";
        home = "/home/kioskadmin";
        shell = "/run/current-system/sw/bin/zsh";
        uid = 1000;
        isNormalUser = true;
	hashedPassword = "$y$j9T$5fxR9An0pF.rgp07lLJxY1$1T5TkKiVEE7scgxhy00D50zaGGJuarElu.U4X7nX9q7";
        openssh.authorizedKeys.keys = sshKeys;
      };
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.kioskadmin = import ./home.nix;

    programs.neovim.enable = true;
    programs.zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [];
      };
    };
  };
}
