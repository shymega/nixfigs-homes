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
} @ args: let
  inherit (libx) isPC homePrefix;
  inherit (lib) getExe getExe';
  isModule = builtins.hasAttr "osConfig" args;
  getHomeDirectory = username: homePrefix + "/${username}";
  homeDirectory = getHomeDirectory username;
  rustCrates = with pkgs; [
    aichat
    bacon
    bandwhich
    cargo-binutils
    cargo-bloat
    cargo-bootimage
    cargo-cross
    cargo-deny
    cargo-dist
    cargo-edit
    cargo-embassy
    espflash
    cargo-espmonitor
    cargo-expand
    cargo-generate
    cargo-expand
    cargo-lambda
    cargo-license
    cargo-make
    cargo-update
    cargo-watch
    cargo-workspaces
    cargo-xbuild
    difftastic
    dust
    duf
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
    onepassword-shell-plugins.hmModules.default
    shypkgs-public.hmModules.${hostPlatform}.dwl
    nixfigs-secrets.user
    shyemacs-cfg.homeModules.emacs
    stylix.homeModules.stylix
  ];

  nix =
    if !isModule
    then {
      settings = rec {
        substituters = lib.mkForce [
          "https://cache.nixos.org/?priority=15"
          "https://nix-community.cachix.org/?priority=10"
          "https://numtide.cachix.org/?priority=14"
          "https://pre-commit-hooks.cachix.org/?priority=16"
        ];
        trusted-public-keys = lib.mkForce [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixbuild.net/VNUM6K-1:ha1G8guB68/E1npRiatdXfLZfoFBddJ5b2fPt3R9JqU="
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
        ];
        builders-use-substitutes = true;
        http-connections = 128;
        max-substitution-jobs = 128;
      };
      package = pkgs.lix;
      registry = {
        home-manager.flake = inputs.home-manager;
        n.flake = inputs.nixpkgs;
        nixpkgs.flake = inputs.nixpkgs;
        nu.flake = inputs.nixpkgs-unstable;
        shypkgs.flake = inputs.shypkgs-public // inputs.shypkgs-public;
      };
      extraOptions = ''
        !include ${config.age.secrets.nix_conf_access_tokens.path}
      '';
    }
    else {
      settings = {
        inherit
          (args.osConfig.nix.settings)
          substituters
          trusted-public-keys
          builders-use-substitutes
          http-connections
          max-substitution-jobs
          ;
      };
      inherit (args.osConfig.nix) registry;
      extraOptions = ''
        !include ${config.age.secrets.nix_conf_access_tokens.path}
      '';
    };

  home = {
    inherit username homeDirectory;
    enableNixpkgsReleaseCheck = true;
    stateVersion = "25.05";
    packages = with pkgs;
      [
        aerc
        age
        agebox
        aider-chat
        alejandra
        alpaca
        alsa-utils
        android-tools
        asciinema
        awscli2
        azure-cli
        b4
        bat
        bc
        beancount
        unstable.beeper
        black
        brightnessctl
        buildpack
        bun
        claude-code
        cloudflared
        cocogitto
        curl
        dateutils
        dex
        diesel-cli
        diffoscope
        difftastic
        distrobox
        dnscontrol
        dogdns
        dosbox
        elf2uf2-rs
        encfs
        exiftool
        expect
        eza
        firefox
        flatpak-xdg-utils
        fuse
        fzf
        gemini-cli
        gh
        glab
        gnucash
        gnumake
        go
        google-chrome
        google-cloud-sdk
        gthumb
        httpie
        hub
        hut
        imagemagick
        imapsync
        inetutils
        ispell
        jdk17
        jq
        leafnode
        ledger
        ledger2beancount
        libnotify
        lynx
        lzip
        m4
        maven
        mkcert
        mpc
        mpv
        mpvScripts.mpris
        mupdf
        ncmpcpp
        neomutt
        networkmanagerapplet
        nh
        nix-init
        nix-prefetch
        nixfmt-rfc-style
        nixpacks
        nixpkgs-fmt
        nixpkgs-review
        nodejs
        notmuch
        offlineimap
        p7zip
        parallel
        pass
        pavucontrol
        pdftk
        pizauth
        playerctl
        poetry
        poppler-utils
        powershell
        pre-commit
        public-inbox
        pw-volume
        pwalarmd
        pwvucontrol
        (python3.withPackages (p: [p.tkinter]))
        python3Packages.pip
        python3Packages.pipx
        python3Packages.virtualenv
        python3Packages.virtualenvwrapper
        q
        ranger
        rclone
        restic
        reuse
        rkvm
        rot8
        ruff
        rustup
        sbcl
        scrcpy
        shikane
        speedtest-go
        spring-boot-cli
        statix
        step-cli
        stow
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
        unstable.devenv
        unzip
        uv
        vdirsyncer
        vlc
        w3m
        wayfarer
        waypipe
        wayvnc
        weechatWithMyPlugins
        wezterm
        wf-recorder
        wget
        whitesur-kde
        wl-mirror
        wlr-randr
        wm-menu
        yubioath-flutter
        zathura
        zellij
        zip
        # (pkgs.doomEmacs {
        #   doomDir = inputs.nixfigs-doom-emacs;
        #   doomLocalDir = "${homeDirectory}/.local/state/doom";
        #   emacs = pkgs.emacs30-pgtk;
        # })
        unstable.isync-patched
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ]
      ++ rustCrates
      ++ (
        with pkgs;
          lib.optionals isPC (with pkgs; [
            android-studio
            android-studio-for-platform
            gcc
            protontricks
            protonup-qt
            steamcmd
            texlive.combined.scheme-full
            virt-manager
            virtiofsd
            wineWowPackages.stable
            winetricks
          ])
      )
      ++ (
        with pkgs; [
          (git-wip.override {
            wipPrefix = "shymega";
          })
        ]
      )
      ++ (with pkgs.unstable.vimPlugins; [
        astrocore
      ])
      ++ rustCrates;
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
      systemdTarget = "wlroots-session.target";
    };
    gnome-keyring = {
      enable = true;
      components = ["secrets"];
    };
    dunst.enable = false;
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
    gammastep = {
      enable = true;
      temperature = {
        day = 6500;
        night = 3400;
      };
      provider = "geoclue2";
    };
    redshift = {
      enable = false;
      temperature = {
        day = 6500;
        night = 3400;
      };
      provider = "geoclue2";
    };
  };

  xdg.systemDirs.data = [
    "/usr/share"
    "/var/lib/flatpak/exports/share"
    "$HOME/.local/share/flatpak/exports/share"
  ];

  programs = {
    _1password-shell-plugins = {
      enable = false;
      plugins = with pkgs; [
        awscli2
        cachix
        flyctl
        gh
        hcloud
        wrangler
      ];
    };
    bash.enable = true;
    obs-studio = lib.optionalAttrs isPC {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
    dwl = {
      enable = true;
      cmd = {
        terminal = "${getExe pkgs.alacritty}";
        editor = "${getExe' pkgs.emacs30-pgtk "emacsclient"} -cq";
        menu = "${getExe' pkgs.rofi "rofi"} -show drun";
      };
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
      package = pkgs.unstable.atuin;
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
      includes = with inputs; [
        {path = "${gitalias}/gitalias.txt";}
      ];
    };
    vscode = {
      enable = true;
      package = pkgs.unstable.vscode.fhs;
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
          ExecStart = "${getExe' pkgs.unstable.atuin "atuin"} daemon";
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
      polkit-gnome-authentication-agent-1 = {
        Unit = {
          Description = "polkit-gnome-authentication-agent-1";
          After = ["default.target"];
          BindsTo = ["default.target"];
          PartOf = ["default.target"];
        };
        Install.WantedBy = ["default.target"];
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
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
          ExecStart = "${getExe' pkgs.unstable.atuin "atuin"} sync";
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
    image = pkgs.fetchurl {
      url = "https://getoutside.ordnancesurvey.co.uk/blobgetoutside5db8a681d3/wp-content/uploads/2024/10/river-nene-circular-walk-2560-x-1440.jpg";
      hash = "sha256-1py6MskXEeG8o30IdDVpWjInWenFxjDWVth2m7X5uOM=";
    };
    targets = {
      alacritty.enable = true;
      kde.enable = false;
      gnome.enable = true;
      hyprland = {
        enable = true;
        hyprpaper.enable = true;
      };
      rofi.enable = true;
      waybar.enable = true;
      tmux.enable = true;
      sway.enable = true;
      swaylock.enable = true;
      hyprlock.enable = true;
    };
  };
}
