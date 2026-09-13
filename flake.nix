{
  description = "Carl Lundin's NixOS systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stock-ticker.url = "github:clundin55/stock-ticker";
    agenix.url = "github:ryantm/agenix";
    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    moonshine.url = "github:hgaiser/moonshine";
    moonshine.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      stock-ticker,
      agenix,
      microvm,
      moonshine,
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
            microvm.nixosModules.host
            moonshine.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.carl = import ./home-manager/home.nix;
              home-manager.extraSpecialArgs = {
                isLaptop = false;
              };
              microvm.vms.claude-code.flake = self;
            }
          ];
        };
        claude-code = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            carlKeys = (import ./shared/keys.nix).carl;
          };
          modules = [
            microvm.nixosModules.microvm
            ./systems/vms/claude-code.nix
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
        carl-rpi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            hostname = "carl-rpi";
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
            {
              services.nginx.streamConfig = ''
                server {
                  listen 443;
                  proxy_pass 192.168.50.33:8888;
                }
              '';
              networking.firewall.allowedTCPPorts = [ 443 ];
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
        zero-rpi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            hostname = "zero-rpi";
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
