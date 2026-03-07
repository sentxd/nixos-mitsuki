{
  description = "Framework 13 Ryzen AI 300";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-pinned.url = "github:nixos/nixpkgs/bfc1b8a4574108ceef22f02bafcf6611380c100d";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-pinned, nixos-hardware, home-manager, lanzaboote, ... }:
  let
    system = "x86_64-linux";
    pinnedPkgs = import nixpkgs-pinned {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.mitsuki = nixpkgs.lib.nixosSystem {
      modules = [
        ({ ... }: { _module.args.pinnedPkgs = pinnedPkgs; })
        
        nixos-hardware.nixosModules.framework-amd-ai-300-series
        lanzaboote.nixosModules.lanzaboote
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
