# This contains configuration settings for beefier / non-battery systems.
{ config, pkgs, ... }: 

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  networking.hostName = "loki";
  networking.networkmanager.enable = true;

  services.xserver.enable = false;
  services.playerctld.enable = true;
  services.tailscale.enable = true;

  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    extraPackages = [pkgs.sddm-astronaut];
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = false;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

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
    ((pkgs.sddm-astronaut.override{ embeddedTheme = "post-apocalyptic_hacker"; }))
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

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.hyprlock.enable = true;
  programs.waybar.enable = true;
}

