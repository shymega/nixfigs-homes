# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  inputs,
  pkgs,
  config,
  username,
  hostPlatform,
  lib,
  libx,
  ...
}: let
  inherit (libx) isPC homePrefix;
  inherit (lib) getExe';
  homeDirectory = let
    getHomeDirectory = username: homePrefix + "/${username}";
  in
    getHomeDirectory username;
  rustCrates = with pkgs; [
    cargo-binutils
    cargo-bloat
    cargo-bootimage
    cargo-cross
    cargo-deny
    cargo-dist
    cargo-edit
    cargo-embassy
    cargo-espmonitor
    cargo-expand
    cargo-generate
    cargo-license
    cargo-make
    cargo-update
    cargo-watch
    cargo-workspaces
    cargo-xbuild
    difftastic
    espflash
    fclones
    fd
    just
    ldproxy
    ripgrep
    starship
    taskwarrior-tui
    tokei
    wasm-pack
    watchexec
    worker-build
    zoxide
  ];
in {
  imports = with inputs; [
    ./network-targets.nix
    ./programs/hyprland.nix
    agenix.homeManagerModules.default
    nix-index-database.homeModules.nix-index
    _1password-shell-plugins.hmModules.default
    nixfigs-secrets.user
    shyemacs-cfg.homeModules.emacs
    stylix.homeModules.stylix
  ];

  home = {
    inherit username homeDirectory;
    enableNixpkgsReleaseCheck = true;
    stateVersion = "26.05";
    packages = with pkgs;
      [
        aerc
        age
        alejandra
        alsa-utils
        android-tools
        asciinema
        b4
        bat
        bc
        brightnessctl
        cloudflared
        cocogitto
        curl
        dateutils
        dex
        difftastic
        distrobox
        dosbox
        elf2uf2-rs
        encfs
        exiftool
        eza
        firefox
        flatpak-xdg-utils
        fuse
        fzf
        gh
        glab
        gnumake
        go
        google-chrome
        gthumb
        halloy
        httpie
        hub
        hut
        imagemagick
        imapsync
        inetutils
        ispell
        jq
        leafnode
        libnotify
        lynx
        m4
        mkcert
        mpc
        mprisence
        mpv
        mupdf
        ncmpcpp
        neomutt
        networkmanagerapplet
        nh
        nix-prefetch
        nixfmt
        nixpkgs-review
        nodejs
        notmuch
        p7zip
        pass
        pdftk
        pizauth
        playerctl
        pre-commit
        public-inbox
        pwvucontrol
        python3Packages.pip
        python3Packages.virtualenv
        python3Packages.virtualenvwrapper
        q
        ranger
        rclone
        restic
        reuse
        rkvm
        rofi
        rot8
        ruff
        rustup
        sbcl
        scrcpy
        senpai
        shikane
        speedtest-go
        spring-boot-cli
        statix
        step-cli
        swaks
        taskwarrior-tui
        tea
        tigervnc
        timewarrior
        tmuxp
        toolbox
        totp
        twilight-kde
        units
        unrar
        unstable.claude-code
        unstable.devenv
        unstable.gemini-cli
        unstable.isync-patched
        unstable.opencode
        unzip
        uv
        vdirsyncer
        w3m
        wayfarer
        waypipe
        wayvnc
        wezterm
        wf-recorder
        wget
        whitesur-kde
        wl-mirror
        wlr-randr
        wm-menu
        zathura
        zellij
        zip
        (pkgs.doomEmacs {
          doomDir = inputs.nixfigs-doom-emacs;
          doomLocalDir = "${homeDirectory}/.local/state/doom";
          emacs = pkgs.emacs-pgtk;
          experimentalFetchTree = true;
        })
        inputs.agenix.packages.${hostPlatform}.default
      ]
      ++ rustCrates
      ++ (
        with pkgs;
          lib.optionals isPC (
            with pkgs; [
              android-studio
              android-studio-for-platform
              texlive.combined.scheme-full
              virt-manager
              virtiofsd
            ]
          )
      )
      ++ (with pkgs; [(git-wip.override {wipPrefix = "shymega";})])
      ++ rustCrates
      ++ [inputs.snappy-switcher.packages.${hostPlatform}.default];
  };

  services = {
    swaync.enable = true;
    darkman = {
      enable = true;
      package = pkgs.darkman;
      settings = {
        usegeoclue = true;
      };
      darkModeScripts.gtk-theme = ''
        ${getExe' pkgs.dconf "dconf"} write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
      '';

      lightModeScripts.gtk-theme = ''
        ${getExe' pkgs.dconf "dconf"} write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
      '';
    };
    keybase.enable = true;
    gpg-agent = {
      enable = true;
      pinentry.package = lib.mkForce pkgs.pinentry-gtk2;
      enableScDaemon = true;
      enableSshSupport = false;
      enableExtraSocket = true;
      grabKeyboardAndMouse = true;
      defaultCacheTtl = 34560000;
      maxCacheTtl = 34560000;
      extraConfig = ''
        auto-expand-secmem
        allow-preset-passphrase
        allow-emacs-pinentry
        allow-loopback-pinentry
      '';
    };
    kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
    };
    gnome-keyring = {
      enable = true;
      components = ["secrets"];
    };
    mpd-discord-rpc.enable = true;
    mpris-proxy.enable = true;
    mpdris2.enable = true;
    emacs = {
      enable = true;
      client.enable = true;
      startWithUserSession = true;
      socketActivation.enable = true;
    };
    mpd = {
      enable = true;
      musicDirectory = "${config.home.homeDirectory}/Multimedia/Music/";
      extraConfig = ''
        audio_output {
            type "pipewire"
            name "PipeWire Output"
        }
      '';
    };
  };

  xdg.systemDirs.data = [
    "/usr/share"
    "/var/lib/flatpak/exports/share"
    "$HOME/.local/share/flatpak/exports/share"
  ];

  programs = {
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
        awscli2
        cachix
        flyctl
        gh
        hcloud
        wrangler
      ];
    };
    zsh.enable = false;
    bash.enable = true;
    obs-studio = lib.optionalAttrs isPC {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
    yt-dlp.enable = true;
    htop.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      plugins = [
        # Enable a plugin (here grc for colorized command output) from nixpkgs
        {
          name = "grc";
          inherit (pkgs.fishPlugins.grc) src;
        }
        {
          name = "done";
          inherit (pkgs.fishPlugins.done) src;
        }
        {
          name = "sponge";
          inherit (pkgs.fishPlugins.sponge) src;
        }
      ];
    };
    atuin = {
      enable = true;
      package = pkgs.atuin;
      enableBashIntegration = true;
      enableFishIntegration = true;
      settings = {
        style = "auto";
        inline_height = 0;
        key_path = config.age.secrets.atuin_key.path;
        sync_address = "https://api.atuin.sh";
        auto_sync = true;
        dialect = "uk";
        secrets_filter = true;
        enter_accept = false;
        workspaces = true;
        sync_frequency = 900;
        sync = {
          records = true;
        };
        daemon = {
          enabled = true;
          systemd_socket = true;
          sync_frequency = 900;
        };
      };
    };
    nix-index-database.comma.enable = true;
    rbw.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
      settings.alias = {
        aa = "add --all";
        amend = "commit --amend";
        br = "branch";
        checkpoint = "stash --include-untracked; stash apply";
        cp = "checkpoint";
        cm = "commit -m";
        co = "checkout";
        dc = "diff --cached";
        dft = "difftool";
        hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
        lg = "log --graph --branches --oneline --decorate --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C";
        loc = "!git diff --stat `git hash-object -t tree /dev/null` | tail -1 | cut -d' ' -f5";
        st = "status -sb";
        sum = "log --oneline --no-merges";
        unstage = "reset --soft HEAD";
        revert = "revert --no-edit";
        squash-all = "!f(){ git reset $(git commit-tree HEAD^{tree} -m 'A new start');};f";
      };
      includes = with inputs; [{path = "${gitalias}/gitalias.txt";}];
    };
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    home-manager.enable = true;
    taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior2;
      config = {
        report = {
          minimal.filter = "status:pending";
          active.columns = [
            "id"
            "start"
            "entry.age"
            "priority"
            "project"
            "due"
            "description"
          ];
          active.labels = [
            "ID"
            "Started"
            "Age"
            "Priority"
            "Project"
            "Due"
            "Description"
          ];
        };
      };
    };
  };
  news.display = "silent";

  systemd.user = let
    atuinDataDir = "${config.xdg.dataHome}/atuin";
    atuinCommonConfig = {
      ConditionPathIsDirectory = atuinDataDir;
      ConditionPathExists = "${config.xdg.configHome}/atuin/config.toml";
    };
    taskwCommonConfig = {
      ConditionPathExists = "${config.xdg.configHome}/task/taskrc";
      ConditionPathIsDirectory = "${config.xdg.dataHome}/task";
    };
  in {
    sockets.atuin-daemon = {
      Unit = {
        Description = "Unix socket activation for atuin shell history daemon";
      };

      Socket = {
        ListenStream = "%t/atuin.sock";
        SocketMode = "0600";
        RemoveOnStop = true;
      };

      Install = {
        WantedBy = ["sockets.target"];
      };
    };

    timers = {
      atuin-sync = {
        Unit =
          atuinCommonConfig
          // {
            Description = "Atuin - Sync Service Timer";
          };
        Timer.OnCalendar = "*:0/30";
        Install.WantedBy = ["timers.target"];
      };
      task-sync = {
        Unit =
          taskwCommonConfig
          // {
            Description = "Taskwarrior auto sync timer";
          };
        Timer.OnCalendar = "*:0/30";
        Install.WantedBy = ["timers.target"];
      };
    };
    sessionVariables = {
      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
      MOZ_ENABLE_WAYLAND = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
    tmpfiles.rules = ["L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0"];
    services = {
      atuin-daemon = {
        Unit = {
          Description = "atuin shell history daemon";
          Requires = ["atuin-daemon.socket"];
        };
        Service = {
          ExecStart = "${getExe' pkgs.atuin "atuin"} daemon";
          Environment = ["ATUIN_LOG=info"];
          Restart = "on-failure";
          RestartSteps = 5;
          RestartMaxDelaySec = 10;
        };
        Install = {
          Also = ["atuin-daemon.socket"];
          WantedBy = ["default.target"];
        };
      };
      atuin-sync = {
        Unit =
          atuinCommonConfig
          // {
            Description = "Atuin - Sync Service";
          };
        Service = {
          Type = "oneshot";
          ExecStart = "${getExe' pkgs.atuin "atuin"} sync";
        };
      };
      task-sync = {
        Unit =
          taskwCommonConfig
          // {
            Description = "Taskwarrior auto sync service";
          };
        Service = {
          Type = "oneshot";
          ExecStartPre = "${getExe' pkgs.taskwarrior2 "task"}";
          ExecStart = "${getExe' pkgs.taskwarrior2 "task"} sync";
          ExecStartPost = "${getExe' pkgs.taskwarrior2 "task"} sync";
        };
      };
    };
  };
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/zenburn.yaml";
    image = inputs.wallpaper;
    targets = {
      alacritty.enable = true;
      gnome.enable = true;
      kde.enable = true;
      hyprland = {
        enable = true;
        hyprpaper.enable = false;
      };
      hyprlock.enable = false;
      rofi.enable = true;
      sway.enable = true;
      swaylock.enable = true;
      tmux.enable = true;
      waybar.enable = true;
    };
  };
}
