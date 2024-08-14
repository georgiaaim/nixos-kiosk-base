{
  description = "Base UGA Module Factory Kiosk Configuration for ZimaBoard";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, disko }: {
    nixosModules.baseEnvironment = {
      imports = [
        home-manager.nixosModules.home-manager 
        disko.nixosModules.disko
        ./boot.nix
        ./disks.nix
        ./net.nix
        ./users
      	./sw.nix
      ];
    };
  };
}
