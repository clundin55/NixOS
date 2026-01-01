{
  description = "Carl Lundin's NixOS systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stock-ticker.url = "github:clundin55/stock-ticker";
    agenix.url = "github:ryantm/agenix";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      stock-ticker,
      agenix,
      ...
    }:
    {
      nixosConfigurations = {
        loki = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            stock-ticker = stock-ticker.packages."x86_64-linux".default;
          };
          modules = [
            ./configuration.nix
            ./systems/desktop/desktop.nix
            ./systems/desktop/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.carl = import ./home-manager/home.nix;
              home-manager.extraSpecialArgs = {
                isLaptop = false;
              };
            }
          ];
        };
        freia = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            stock-ticker = stock-ticker.packages."x86_64-linux".default;
          };
          modules = [
            ./configuration.nix
            ./systems/laptop/laptop.nix
            ./systems/laptop/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.carl = import ./home-manager/home.nix;
              home-manager.extraSpecialArgs = {
                isLaptop = true;
              };
            }
          ];
        };
        kyle-rpi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            hostname = "kyle-rpi";
          };
          modules = [
            ./systems/rpi/rpi.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.carl = import ./home-manager/home.nix;
              home-manager.extraSpecialArgs = {
                isLaptop = true;
              };
            }
          ];
        };
        brian-rpi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            hostname = "brian-rpi";
          };
          modules = [
            ./systems/rpi/rpi.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.carl = import ./home-manager/home.nix;
              home-manager.extraSpecialArgs = {
                isLaptop = true;
              };
            }
          ];
        };
      };
    };
}
