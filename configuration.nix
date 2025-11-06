{
  config,
  pkgs,
  agenix,
  stock-ticker,
  ...
}:
let
  scripts = import ./shared/scripts.nix { inherit config pkgs stock-ticker; };
in
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

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.carl = {
    isNormalUser = true;
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
  nixpkgs.overlays = [
    (self: super: {
      mpv = super.mpv.override {
        scripts = [ self.mpvScripts.mpris ];
      };
    })
  ];

  age.secrets = {
    pmp_key = {
      file = ./secrets/pmp_key.age;
      mode = "400";
      owner = "carl";
      group = "users";
    };
    user_pass = {
      file = ./secrets/user_pass.age;
      mode = "400";
      owner = "carl";
      group = "users";
    };
  };

  environment.systemPackages = with pkgs; [
    alacritty
    bash
    bluetui
    vim
    wl-clipboard
    zip
    unzip
    mullvad
    yazi
    yt-dlp
    zathura
    hyprpaper
    mako
    libnotify
    cava
    pass
    stock-ticker
    waybar
    xwayland-satellite
    google-chrome
    gemini-cli
    waypipe
    zellij
    jujutsu
    clang
    rustup
    mpv
    mpvScripts.mpris
    scripts.vpn-status
    scripts.weather
    scripts.stock-price
    ((pkgs.sddm-astronaut.override { embeddedTheme = "black_hole"; }))
  ];
  environment.pathsToLink = [ "/share/zsh" ];

  services.mullvad-vpn.enable = true;

  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    extraPackages = [ pkgs.sddm-astronaut ];
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = false;

  programs.niri.enable = true;
  programs.hyprlock.enable = true;
  programs.firefox.enable = true;

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

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
  services.flatpak.enable = true;

  services.openssh.enable = true;

  system.stateVersion = "24.11";
}
