{ config, pkgs, ... }: 

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "floki";
  networking.networkmanager.enable = true;

  services.xserver.enable = false;
  services.tailscale.enable = true;

  services.pulseaudio.enable = false;

  environment.systemPackages = with pkgs; [
    clang
  ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  services.flatpak.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  nix.settings.trusted-users = [ "carl" ];

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}

