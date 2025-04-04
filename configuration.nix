# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "loki"; # Define your hostname.
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc.automatic = true;
  nix.gc.persistent = true;
  nix.gc.dates = "weekly";

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
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

  # Configure keymap in X11
  # services.xserver.xkb = {
  #   layout = "us";
  #   variant = "";
  # };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.carl = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Carl Lundin";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wl-clipboard
    zsh
    zip
    unzip
    hyprpaper
    transmission_4
    nvtopPackages.amd
    rustup
    gdb
    mullvad
    ((pkgs.sddm-astronaut.override{ embeddedTheme = "post-apocalyptic_hacker"; }))
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # Use flatpak for:
  # Spotify
  # Discord
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.hyprlock.enable = true;
  programs.waybar.enable = true;

  services.ollama.enable = true;
  services.ollama.rocmOverrideGfx = "10.3.0";
  services.ollama.acceleration = "rocm";

  hardware.amdgpu.opencl.enable = true;
  hardware.bluetooth.enable = false;

  services.blueman.enable = false;
  services.mullvad-vpn.enable = true;

  virtualisation.docker.enable = true;

  # Add udev rules for: 
  # - Xilinx FTDI chip.
  # - SDWIRE FTDI chip.
  services.udev.extraRules = ''
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", OWNER="carl", GROUP="users"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="6001", OWNER="carl", GROUP="users"
  '';

  system.stateVersion = "24.11";
}
