{
  pkgs,
  lib,
  isLaptop ? false,
  ...
}:
let
  pinentry-fingerprint = pkgs.writeShellScriptBin "pinentry" ''
    PASSPHRASE_FILE="/run/agenix/gpg_passphrase"
    FALLBACK="${pkgs.pinentry-tty}/bin/pinentry"

    # In clamshell mode (lid closed, docked) the fingerprint reader is awkward
    # to reach, so fall back to passphrase entry.
    if ${pkgs.ripgrep}/bin/rg -q closed /proc/acpi/button/lid/*/state 2>/dev/null; then
      exec "$FALLBACK" "$@"
    fi

    if [ ! -f "$PASSPHRASE_FILE" ]; then
      exec "$FALLBACK" "$@"
    fi

    printf 'Scan fingerprint to unlock GPG key...\n' >&2
    if ! ${pkgs.fprintd}/bin/fprintd-verify "$USER" >&2; then
      exec "$FALLBACK" "$@"
    fi

    PASSPHRASE=$(tr -d '\n' < "$PASSPHRASE_FILE")

    printf 'OK Pleased to meet you\n'
    while IFS= read -r cmd; do
      cmd="''${cmd%%$'\r'}"
      case "$cmd" in
        GETPIN*) printf 'D %s\nOK\n' "$PASSPHRASE" ;;
        BYE*)    printf 'OK closing connection\n'; exit 0 ;;
        *)       printf 'OK\n' ;;
      esac
    done
  '';

  # swaybg only ever shows one image, so rotate by starting a fresh instance and
  # killing the previous one once the new one has painted.
  swaybg-rotate = pkgs.writeShellScriptBin "swaybg-rotate" ''
    set -u

    dir="''${1:-$HOME/Pictures/wallpapers}"
    interval="''${2:-300}"
    overlap=2

    prev=""

    cleanup() {
      [ -n "$prev" ] && kill "$prev" 2>/dev/null
      exit 0
    }
    trap cleanup TERM INT

    while :; do
      readarray -t images < <(
        find -L "$dir" -type f \
          \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
             -o -iname '*.webp' -o -iname '*.bmp' \) | shuf
      )

      if [ ''${#images[@]} -eq 0 ]; then
        echo "swaybg-rotate: no wallpapers found in $dir" >&2
        sleep 60
        continue
      fi

      for img in "''${images[@]}"; do
        ${pkgs.swaybg}/bin/swaybg -i "$img" -m fill &
        next=$!

        # Let the new instance render before tearing down the old one.
        sleep "$overlap"
        if [ -n "$prev" ]; then
          kill "$prev" 2>/dev/null
          wait "$prev" 2>/dev/null
        fi
        prev=$next

        if [ "$interval" -gt "$overlap" ]; then
          sleep "$((interval - overlap))"
        fi
      done
    done
  '';
in
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
    nixfmt
    nixfmt-tree
    rclone
    tree-sitter
    gcc
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
        gp = [
          "git"
          "push"
        ];
        gf = [
          "git"
          "fetch"
        ];
        b = [
          "bookmark"
          "set"
          "-r"
          "@-"
        ];
        bc = [
          "bookmark"
          "create"
          "-r"
          "@-"
        ];
        l = [
          "log"
          "-r"
        ];
        lc = [
          "log"
          "-r"
          "@::"
        ];
        ld = [
          "log"
          "-r"
          "::@"
        ];
      };
      remotes = {
        origin = {
          auto-track-bookmarks = "glob:*";
        };
        upstream = {
          auto-track-bookmarks = "main";
        };
      };
      git = {
        # Prevent pushing work in progress or anything explicitly labeled "private"
        private-commits = "description(glob:'private:*')";
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

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "hyprlock";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
      ]
      ++ lib.optionals isLaptop [
        {
          timeout = 600;
          on-timeout = "niri msg action power-off-monitors";
          on-resume = "niri msg action power-on-monitors";
        }
        {
          timeout = 900;
          on-timeout = "grep -q open /proc/acpi/button/lid/LID0/state && systemctl suspend";
        }
      ];
    };
  };

  systemd.user.services.swaybg = {
    Unit = {
      Description = "swaybg wallpaper (rotating)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      # Cycle through ~/Pictures/wallpapers, changing every 5 minutes.
      ExecStart = "${swaybg-rotate}/bin/swaybg-rotate %h/Pictures/wallpapers 300";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentry.package = if isLaptop then pinentry-fingerprint else pkgs.pinentry-tty;
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
  home.stateVersion = "26.05";
}
