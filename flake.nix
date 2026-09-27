{
  description = "mestorixx NixOS — chungie-laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.chungie-laptop = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/chungie-laptop
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mestorixx = import ./home/hosts/chungie-laptop.nix;
          }
        ];
      };
    };
}
