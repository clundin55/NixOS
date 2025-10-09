{ config, pkgs, stock-ticker, agenix, ... }:
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
    passwordFile = config.age.secrets.user_pass.path;
  };

  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  nixpkgs.config.allowUnfree = true;

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
    # Cool to trick to embed a rust binary in Nix.
    # Can also do this with python, go, etc.
    ((pkgs.writers.writeRustBin "rust-test" {} ''
        fn main() {
          println!("Hello world");
        }
      ''
    ))
    ((pkgs.sddm-astronaut.override{ embeddedTheme = "post-apocalyptic_hacker"; }))
    ((pkgs.writeScriptBin "vpn-status.sh" ''
    #!${pkgs.bash}/bin/bash

    set -eu
    STATUS=$(mullvad status -j | jq '.state' -r)

    if [[ "''${STATUS}" == "connected" ]]; then
        echo "🔒 $(mullvad status -j | jq '.details.location.city' -r)"
    else
        echo "🔓"
    fi
    ''))
    ((pkgs.writeScriptBin "weather.sh" ''
    #!${pkgs.bash}/bin/bash

    set -eu
    curl -s 'wttr.in/North+Bend+WA?format=3&u' | sed 's/+/ /g' | tr '\n' ' '

    ''))
    ((pkgs.writeScriptBin "stock-price.sh" ''
    #!${pkgs.bash}/bin/bash

    set -eu
    export PMP_KEY=$(cat "${config.age.secrets.pmp_key.path}")
    stock-ticker --tickers GOOG
    ''))
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

  system.stateVersion = "24.11";
}
