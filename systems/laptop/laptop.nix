# This contains configuration settings for laptop systems.
{ config, pkgs, ... }: 

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = ["resume_offset=32563200"];
  boot.resumeDevice = "/dev/disk/by-uuid/a4be4019-5beb-4f5f-9d16-341c6bfbdf2f";

  powerManagement.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];

  networking.hostName = "freia";
  networking.networkmanager.enable = true;

  services.xserver.enable = false;
  services.playerctld.enable = true;
  services.tailscale.enable = true;
  services.fwupd.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    clang
    fwupd
    brightnessctl
    mpv
  ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  services.flatpak.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.udev.extraHwdb = ''
    evdev:atkbd:*
      KEYBOARD_KEY_3a=esc
  '';
}

