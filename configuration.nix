{ config, pkgs, ... }:

{
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

  networking.extraHosts = "192.168.50.33 local.clundin.dev";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.carl = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Carl Lundin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPHPeLSIQgoO2MZCxAXoVxaaZVC0hp1oa81cFO3/zDf carl@nixos"
    ];
  };

  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    alacritty
    vim
    wl-clipboard
    zip
    unzip
    mullvad
    hyprpaper
    yazi
    yt-dlp
    zathura
    ((pkgs.sddm-astronaut.override{ embeddedTheme = "post-apocalyptic_hacker"; }))
  ];
  environment.pathsToLink = [ "/share/zsh" ];

  services.mullvad-vpn.enable = true;

  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    extraPackages = [pkgs.sddm-astronaut];
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = false;

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.hyprlock.enable = true;
  programs.waybar.enable = true;
  programs.firefox.enable = true;

  system.stateVersion = "24.11";
}
