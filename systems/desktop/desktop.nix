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

  services.xserver.enable = false;
  services.playerctld.enable = true;
  services.tailscale.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
    rustup
    gdb
    clang
    go
    gopls
    ccls
    bear
    gnumake
  ];

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  services.flatpak.enable = true;

  nixpkgs.config.rocmSupport = true;
  services.ollama = {
    enable = true;
    rocmOverrideGfx = "10.3.0";
    acceleration = "rocm";
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
}

