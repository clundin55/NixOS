# This contains configuration settings for beefier / non-battery systems.
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  networking.hostName = "loki";
  networking.networkmanager.enable = true;

  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
    gdb
    clang
    go
    gopls
    ccls
    gnumake
  ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.X11Forwarding = true;
  services.openssh.settings.GatewayPorts = "yes";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.rocmSupport = true;
  services.ollama = {
    enable = true;
    rocmOverrideGfx = "10.3.0";
    package = pkgs.ollama-rocm;
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.2";
    };
  };

  hardware.amdgpu.opencl.enable = true;
  hardware.bluetooth.enable = false;
  services.blueman.enable = false;

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Bridge networking for microvms
  systemd.network.enable = true;
  systemd.network.netdevs."10-microvm-br" = {
    netdevConfig = {
      Kind = "bridge";
      Name = "microvm-br";
    };
  };
  systemd.network.networks."10-microvm-br" = {
    matchConfig.Name = "microvm-br";
    networkConfig.Address = "10.0.100.1/24";
  };
  systemd.network.networks."10-vm-claude" = {
    matchConfig.Name = "vm-claude";
    networkConfig.Bridge = "microvm-br";
  };
  # Keep NetworkManager from managing the bridge and TAP
  networking.networkmanager.unmanaged = [ "microvm-br" "vm-claude" ];

  # NAT so the VM can reach the internet
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "microvm-br" ];
  networking.nat.externalInterface = "enp8s0";
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
}
