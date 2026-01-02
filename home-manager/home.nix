{
  pkgs,
  isLaptop ? false,
  ...
}:

{
  home.username = "carl";
  home.homeDirectory = "/home/carl";
  home.language.base = "en_US.UTF-8";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    defaultKeymap = "viins";
    syntaxHighlighting.enable = true;
    initContent = ''
      randir()
      {
        TMP_DIR=$(mktemp -d)
        pushd $TMP_DIR
      }
      tmks() {
        tmux kill-session -t $(tmux ls | fzf | cut -d' ' -f 1)
      }
      tma() {
        tmux a -t $(tmux ls | fzf | cut -d' ' -f 1)
      }
      function rndd() {
          DIR=$(mktemp -d)
          pushd $DIR
      }
    '';
    history = {
      append = true;
      expireDuplicatesFirst = true;
      extended = true;
      findNoDups = true;
      ignoreAllDups = true;
      ignoreDups = true;
      save = 10000;
      size = 10000;
      share = true;
    };
    shellAliases = {
      rzsh = "source ~/.zshrc";
      gr = "git r -v";
      grs = "git reset";
      grsh = "git reset --hard";
      gb = "git b";
      gc = "git c";
      gd = "git diff";
      gsw = "git sw";
      gl = "git l";
      gst = "git st";
      gsh = "git show";
      gps = "git ps";
      gpl = "git pull --rebase";
      gpsf = "git ps --force-with-lease";
      gf = "git fetch";
      grb = "git rebase";
    };
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
    nixfmt-rfc-style
    nixfmt-tree
  ];

  home.file = {
    ".config/nvim/init.lua".source = dotfiles/nvim.lua;
    ".config/mako/config".source = dotfiles/mako;
    ".config/niri/config.kdl".source = dotfiles/niri.kdl;
    ".config/hypr/hyprlock.conf".source = dotfiles/hyprlock.conf;
    ".config/zellij/config.kd".source = dotfiles/zellij.kdl;
    ".config/waybar/config".source =
      if isLaptop then dotfiles/laptop/waybar.conf else dotfiles/waybar.conf;
    ".config/waybar/style.css".source =
      if isLaptop then dotfiles/laptop/waybar.style else dotfiles/waybar.style;
  };

  home.sessionVariables = {
    USING_HOME_MANAGER = "true";
    EDITOR = "nvim";
  };

  programs.difftastic = {
    enable = true;
    options.display = "inline";
    git.diffToolMode = true;
    git.enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Carl Lundin";
      user.email = "carllundin55@gmail.com";
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
      url = {
        "git@github.com" = {
          insteadOf = "github";
        };
      };
    };
    ignores = [
      "*.swp"
    ];
  };

  programs.scmpuff = {
    enable = true;
    enableAliases = true;
    enableZshIntegration = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Carl Lundin";
        email = "carllundin55@gmail.com";
      };
      aliases = {
        gp = ["git" "push"];
        gf = ["git" "fetch"];
        l = ["log" "-r"];
        lc = ["log" "-r" "@::"];
        ld = ["log" "-r" "::@"];
      };
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

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/Pictures/wallpaper.png" ];
      wallpaper = [ ", ~/Pictures/wallpaper.png" ];
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-tty;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font.size = 12.0;
      font.normal = {
        family = "FiraCode Nerd Font";
        style = "Regular";
      };

      selection.save_to_clipboard = true;

      window = {
        decorations = "None";
        dynamic_title = true;
        opacity = 0.6;
        startup_mode = "Windowed";
        title = "Alacritty";
        option_as_alt = "OnlyLeft";
      };

      window.padding = {
        x = 16;
        y = 16;
      };
    };
    theme = "nord";
  };

  programs.readline = {
    enable = true;
    extraConfig = ''
      set editing-mode vi
      set keymap vi
      set bell-style none
      set blink-matching-paren on
      set colored-stats on
      set completion-ignore-case on
      set completion-map-case on
      set completion-map-case on
    '';
  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
