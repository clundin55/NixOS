{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

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
    vim
    git
    wl-clipboard
    zip
    unzip
    mullvad
  ];

  services.mullvad-vpn.enable = true;
  system.stateVersion = "24.11";
}
