{ config, pkgs, ... }:

{
  home.username = "carl";
  home.homeDirectory = "/home/carl";
  home.language.base = "en_US.UTF-8";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    plugins = [
      {
        # will source zsh-autosuggestions.plugin.zsh
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.1";
          sha256 = "vpTyYq9ZgfgdDsWzjxVAE7FZH4MALMNZIFyEOBLm5Qo=";
        };
      }
    ];
  };
  home.shell.enableZshIntegration = true;

  home.packages = [
    pkgs.alacritty
    pkgs.zsh
    pkgs.tmux
    pkgs.neovim
    pkgs.ripgrep
    pkgs.fzf
    pkgs.jq
    pkgs.gh # GitHub CLI
    pkgs.htop
    pkgs.fd
    pkgs.difftastic # binary is difft
    pkgs.tealdeer
    pkgs.pass
    pkgs.gnupg
    pkgs.pinentry-tty
    pkgs.tree
    pkgs.scmpuff
    pkgs.go
    pkgs.gopls
  ];

  home.file = {
    ".zshrc".source = dotfiles/zshrc;
    ".inputrc".source = dotfiles/inputrc;
    ".tmux.conf".source = dotfiles/tmuxconf;
    ".config/nvim/init.lua".source = dotfiles/nvimlua;
    ".config/alacritty/alacritty.toml".source = dotfiles/alacrittytoml;
    ".config/alacritty/darcula.toml".source = dotfiles/darculatoml;
    ".config/alacritty/paper.toml".source = dotfiles/papertoml;
    ".config/hypr/hyprland.conf".source = dotfiles/hyprlandconf;
    ".config/hypr/hyprpaper.conf".source = dotfiles/hyprpaperconf;
    ".config/waybar/config".source = dotfiles/waybarconf;
    ".config/waybar/style.css".source = dotfiles/waybarstyle;
  };

  home.sessionVariables = {
      USING_HOME_MANAGER = "true";
      EDITOR = "nvim";
      GIT_EXTERNAL_DIFF = "difft";
  };

  programs.git = {
    enable = true;
    userName = "Carl Lundin";
    userEmail = "carllundin55@gmail.com";
    aliases = {
      "b" = "branch";
      "co" = "checkout";
      "c" = "commit";
      "r" = "remote";
      "d" = "diff";
      "sw" = "switch";
      "rs" = "reset";
      "l" = "log";
      "st" = "stash";
      "ps" = "push";
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
