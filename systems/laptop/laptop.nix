# This contains configuration settings for laptop systems.
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Microphone workaround
  services.pipewire.wireplumber.extraConfig.no-ucm = {
    "monitor.alsa.properties" = {
      "alsa.use-ucm" = false;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = [ "resume_offset=32563200" ];
  boot.resumeDevice = "/dev/disk/by-uuid/a4be4019-5beb-4f5f-9d16-341c6bfbdf2f";

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=15m
  '';

  services.hardware.bolt.enable = true;
  # Breaks hibernate to sleep
  services.fprintd.enable = false;

  powerManagement.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];

  networking.hostName = "freia";
  networking.networkmanager.enable = true;

  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    fwupd
    brightnessctl
    moonlight-qt
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.udev.extraHwdb = ''
    evdev:atkbd:*
      KEYBOARD_KEY_3a=esc
  '';
}
