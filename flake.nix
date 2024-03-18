{
  description = "Base UGA Module Factory Kiosk Configuration for ZimaBoard";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosModules.baseEnvironment = {
      imports = [
        home-manager.nixosModules.home-manager 
        ./configuration.nix
        ./users.nix
      	./software.nix
      ];
    };
  };
}
