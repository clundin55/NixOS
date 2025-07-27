{ config, pkgs, ... }: 

{
  imports = [
    ./hardware-configuration.nix
  ];

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
}

