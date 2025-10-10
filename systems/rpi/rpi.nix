{ config, pkgs, hostname, ... }: 
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  imports = [
    ./hardware-configuration.nix
  ];

  systemd.user.services.jellyfin = {
    enable = true;
    description = "Jellyfin reverse proxy";
    after = [ "sshd.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "ssh carl@100.113.49.85 -L 8096:127.0.0.1:8096 -G -N";
      Restart = "on-failure";
      RestartSec = "15s";
    };
  };

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

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  services.xserver.enable = false;

  services.tailscale.enable = true;
  services.pulseaudio.enable = false;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  nix.settings.trusted-users = [ "carl" ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.carl = {
    isNormalUser = true;
    description = "Carl Lundin";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPHPeLSIQgoO2MZCxAXoVxaaZVC0hp1oa81cFO3/zDf carl@nixos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIED50DA1QiJerIlFy8Ea04dm1AOWHCrhflNgblREqb8Z carl@freia"
    ];
    initialPassword = "rpi";
  };

  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    bash
    vim
    zip
    unzip
  ];
  environment.pathsToLink = [ "/share/zsh" ];

  system.stateVersion = "24.11";
}
