{
  description = "Framework 13 Ryzen AI 300";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }: {
    nixosConfigurations.mitsuki = nixpkgs.lib.nixosSystem {
      modules = [
        nixos-hardware.nixosModules.framework-amd-ai-300-series
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.sentinel = import ./home/sentinel.nix;
            backupFileExtension = "backup";
          };
        }
        ./configuration.nix
      ];
    };
  };
}
