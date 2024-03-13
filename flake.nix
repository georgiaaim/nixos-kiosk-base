{
  description = "A simple NixOS flake for ZimaBoard";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager 
        /etc/nixos/hardware-configuration.nix
        ./configuration.nix
        ./users.nix
        ({pkgs, lib, ...}: {
          services.kioskAdmin.enable = true;
        })
	./software.nix
      ];
    };
  };
}
