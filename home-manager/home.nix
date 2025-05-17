{ pkgs, isLaptop ? false, ... }:

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

  home.packages = with pkgs; [
    neovim
    ripgrep
    fzf
    jq
    gh
    htop
    fd
    difftastic
    tealdeer
    pass
    gnupg
    pinentry-tty
    tree
    scmpuff
  ];

  home.file = {
    ".zshrc".source = dotfiles/zshrc;
    ".inputrc".source = dotfiles/inputrc;
    ".config/nvim/init.lua".source = dotfiles/nvim.lua;
    ".config/alacritty/alacritty.toml".source = dotfiles/alacritty.toml;
    ".config/alacritty/darcula.toml".source = dotfiles/darcula.toml;
    ".config/alacritty/paper.toml".source = dotfiles/paper.toml;
    ".config/hypr/hyprland.conf".source = dotfiles/hyprland.conf;
    ".config/hypr/hyprlock.conf".source = dotfiles/hyprlock.conf;
    ".config/hypr/hyprpaper.conf".source = dotfiles/hyprpaper.conf;
    ".config/waybar/config".source = if isLaptop then dotfiles/laptop/waybar.conf else dotfiles/waybar.conf;
    ".config/waybar/style.css".source = if isLaptop then dotfiles/laptop/waybar.style else dotfiles/waybar.style;
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
      "rsh" = "reset --hard";
      "l" = "log";
      "st" = "stash";
      "ps" = "push";
    };
  };

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    baseIndex = 1;
    mouse = true;
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.dracula;
        extraConfig = ''
          set -g @dracula-plugins "cpu-usage ram-usage"
          set -g @dracula-show-powerline true
        '';
      }
      {
        plugin = pkgs.tmuxPlugins.sensible;
      }
      {
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60'
        '';
      }
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
    ];
    extraConfig = ''
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      set -g default-terminal "screen-256color"
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      setw -g mode-keys vi
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
      bind-key -T copy-mode-vi 'y' send -X copy-selection-no-clear
      bind-key -n c-a send-prefix
      set -g set-clipboard on 
      set-option -g allow-rename off
    '';
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
