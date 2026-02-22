{
  description = "Framework 13 Ryzen AI 300";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-edge = {
      url = "github:nixos/nixpkgs/bfc1b8a4574108ceef22f02bafcf6611380c100d";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-edge, nixos-hardware, home-manager, lanzaboote, ... }:
  let
    system = "x86_64-linux";
    edgePkgs = import nixpkgs-edge {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.mitsuki = nixpkgs.lib.nixosSystem {
      modules = [
        ({ ... }: { _module.args.edgePkgs = edgePkgs; })
        
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
