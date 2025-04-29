# This contains configuration settings for beefier / non-battery systems.
{ config, pkgs, ... }: 

{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  networking.hostName = "loki";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    hyprpaper
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

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # Use flatpak for:
  # Spotify
  # Discord
  services.flatpak.enable = true;

  services.ollama.enable = true;
  services.ollama.rocmOverrideGfx = "10.3.0";
  services.ollama.acceleration = "rocm";

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

