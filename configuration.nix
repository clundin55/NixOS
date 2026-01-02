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
  nix.gc.options = "--delete-older-than 30d";

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
      "acme"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPHPeLSIQgoO2MZCxAXoVxaaZVC0hp1oa81cFO3/zDf carl@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIED50DA1QiJerIlFy8Ea04dm1AOWHCrhflNgblREqb8Z carl@freia"
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
    namecheap = {
      file = ./secrets/namecheap-api.age;
      mode = "400";
      owner = "acme";
      group = "acme";
    };
  };

  environment.systemPackages = with pkgs; [
    alacritty
    bash
    bluetui
    bitwarden-cli
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
    unrar
    cava
    pass
    stock-ticker
    waybar
    xwayland-satellite
    google-chrome
    gemini-cli
    waypipe
    zellij
    dig
    pstree
    jujutsu
    ssh-tools
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

  systemd.services.weather = {
    script = ''
      #!${pkgs.bash}/bin/bash
      mkdir -p ~/.local/share/weather
      TMP_FILE=$(mktemp)
      ${scripts.weather}/bin/weather.sh > "$TMP_FILE"
      if [ -s "$TMP_FILE" ]; then
        mv "$TMP_FILE" ~/.local/share/weather/north_bend.txt
      else
        rm "$TMP_FILE"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "carl";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
    };
  };

  systemd.timers.weather = {
    wantedBy = [ "timers.target" ];
    partOf = [ "weather.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "weather.service";
      Persistent = true;
    };
  };

  systemd.services.stock-price = {
    script = ''
      #!${pkgs.bash}/bin/bash
      mkdir -p ~/.local/share/stock-price
      TMP_FILE=$(mktemp)
      ${scripts.stock-price}/bin/stock-price.sh > "$TMP_FILE"
      if [ -s "$TMP_FILE" ]; then
        mv "$TMP_FILE" ~/.local/share/stock-price/googl.txt
      else
        rm "$TMP_FILE"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "carl";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
    };
  };

  systemd.timers.stock-price = {
    wantedBy = [ "timers.target" ];
    partOf = [ "stock-price.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "stock-price.service";
      Persistent = true;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "carllundin55@gmail.com";
    certs."clundin.dev" = {
      dnsProvider = "namecheap";
      extraDomainNames = [
        "*.clundin.dev"
      ];
      environmentFile = "${pkgs.writeText "namecheap-creds" ''
        NAMECHEAP_API_KEY_FILE=${config.age.secrets.namecheap.path}
        NAMECHEAP_API_USER=clundin55
      ''}";
    };
  };

  systemd.services.rsync-certs = {
    path = [ pkgs.openssh ];
    script = ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.rsync}/bin/rsync /var/lib/acme/clundin.dev/key.pem odin:home-cluster/key.pem
      ${pkgs.rsync}/bin/rsync /var/lib/acme/clundin.dev/full.pem odin:home-cluster/cert.pem
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "carl";
    };
    after = [ "acme-clundin.dev.service" ];
    wants = [ "acme-clundin.dev.service" ];
  };

  system.stateVersion = "24.11";
}
