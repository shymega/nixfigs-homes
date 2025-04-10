# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  inputs,
  pkgs,
  config,
  username,
  system,
  self,
  lib,
  libx,
  ...
} @ args: let
  inherit (libx) isPC homePrefix;
  inherit (lib) getExe getExe';
  isModule = builtins.hasAttr "osConfig" args;
  osConfig =
    if isModule
    then builtins.getAttr "osConfig" args
    else {};
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
    cargo-espflash
    cargo-espmonitor
    cargo-expand
    cargo-generate
    cargo-inspect
    cargo-lambda
    cargo-license
    cargo-make
    cargo-update
    cargo-watch
    cargo-workspaces
    cargo-xbuild
    difftastic
    du-dust
    duf
    fclones
    fd
    just
    ldproxy
    mates
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
  imports = with inputs;
    [
      ./network-targets.nix
      ./programs/rofi.nix
      ./programs/hyprland.nix
      agenix.homeManagerModules.default
      nix-index-database.hmModules.nix-index
      _1password-shell-plugins.hmModules.default
      shypkgs-public.hmModules.${system}.dwl
      nix-flatpak.homeManagerModules.nix-flatpak
      nixfigs-secrets.user
      lix-module.nixosModules.default
      shyemacs-cfg.homeModules.emacs
    ]
    ++ (
      if !isModule
      then [
        inputs.chaotic.homeManagerModules.default
        (
          {config, ...}: {
            nixpkgs.config = self.nixpkgs-config;
          }
        )
      ]
      else []
    );

  nix =
    if !isModule
    then {
      settings = rec {
        substituters = [
          "https://cache.nixos.org/?priority=10"
          "https://nix-community.cachix.org/?priority=5"
          "https://numtide.cachix.org/?priority=5"
          "https://pre-commit-hooks.cachix.org/?priority=5"
          "ssh://eu.nixbuild.net?priority=50"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixbuild.net/VNUM6K-1:ha1G8guB68/E1npRiatdXfLZfoFBddJ5b2fPt3R9JqU="
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
        ];
        binary-caches = substituters;
        builders-use-substitutes = true;
        http-connections = 128;
        max-substitution-jobs = 128;
      };
      registry = {
        home-manager.flake = inputs.home-manager;
        n.flake = inputs.nixpkgs;
        nixpkgs.flake = inputs.nixpkgs;
        nu.flake = inputs.nixpkgs-unstable;
        shypkgs.flake = inputs.shypkgs-public // inputs.shypkgs-public;
      };
      extraOptions = ''
        builders = @/etc/nix/machines
        !include ${config.age.secrets.nix_conf_access_tokens.path}
      '';
      package = pkgs.nix;
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
        builders = @/etc/nix/machines
        !include ${config.age.secrets.nix_conf_access_tokens.path}
      '';
    };

  home = {
    inherit username homeDirectory;
    enableNixpkgsReleaseCheck = true;
    stateVersion = "24.11";
    packages = with pkgs;
      [
        aerc
        age
        alejandra
        alpaca
        alsa-utils
        android-tools
        asciinema
        aws-sam-cli
        awscli2
        azure-cli
        b4
        bat
        bc
        beeper
        brightnessctl
        buildpack
        bun
        cloudflared
        cocogitto
        curl
        dateutils
        devenv
        dex
        diesel-cli
        difftastic
        distrobox
        dogdns
        dosbox
        elf2uf2-rs
        encfs
        exiftool
        expect
        eza
        firefox
        fuse
        fzf
        glab
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
        libnotify
        m4
        maven
        meli
        mkcert
        moneydance
        mpc-cli
        mpv
        mupdf
        ncmpcpp
        neomutt
        networkmanagerapplet
        nh
        nixfmt-rfc-style
        nixpacks
        nixpkgs-fmt
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
        poppler_utils
        powershell
        pre-commit
        public-inbox
        pw-volume
        pwalarmd
        pwvucontrol
        python3Full
        python3Packages.pip
        python3Packages.pipx
        python3Packages.virtualenv
        q
        ranger
        rclone
        reuse
        rot8
        rustup
        scrcpy
        shikane
        speedtest-go
        spring-boot-cli
        statix
        step-cli
        stow
        swaks
        tea
        tigervnc
        timewarrior
        tmuxp
        totp
        units
        unrar
        unstable.weechatWithMyPlugins
        unzip
        vdirsyncer
        vlc
        w3m
        wayfarer
        wayvnc
        wezterm
        wf-recorder
        wget
        wl-mirror
        wm-menu
        yubikey-manager-qt
        zathura
        zellij
        zip
        (pkgs.doomEmacs {
          doomDir = inputs.nixfigs-doom-emacs;
          doomLocalDir = "${homeDirectory}/.local/state/doom";
          emacs = pkgs.emacs29-pgtk;
        })
        (pkgs.isync.override {withCyrusSaslXoauth2 = true;})
        inputs.agenix.packages.${pkgs.system}.default
      ]
      ++ rustCrates
      ++ (
        with pkgs;
          lib.optionals isPC (
            with pkgs.jetbrains;
              [
                clion
                datagrip
                dataspell
                gateway
                goland
                idea-community
                idea-ultimate
                phpstorm
                pycharm-community
                pycharm-professional
                rider
                ruby-mine
                rust-rover
                webstorm
                writerside
              ]
              ++ (with pkgs; [
                android-studio
                android-studio-for-platform
                deckcheatz
                gcc
                protontricks
                protonup-qt
                steamcmd
                texlive.combined.scheme-full
                virt-manager
                virtiofsd
                wineWowPackages.stable
                winetricks
                xrlinuxdriver
              ])
          )
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
      pinentryPackage = with pkgs; lib.mkForce pinentry-gnome3;
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
    kanshi =
      if isModule && builtins.hasAttr "osConfig.networking.hostName" args
      then
        lib.optionalAttrs (lib.hasSuffix args.osConfig.networking.hostName "-LINUX") {
          enable = false;
          systemdTarget = "wlroots-session.target";
          settings = import ./aux/kanshi-config.nix;
        }
      else {};
    gnome-keyring = {
      enable = true;
      components = ["secrets"];
    };
    dunst.enable = true;
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

  services.flatpak = {
    enable = false;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "flathub-beta";
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
    ];
    packages =
      map (appId: {
        inherit appId;
        origin = "flathub";
      })
      flatpakPackages;
    uninstallUnmanaged = true;
    update.auto = {
      enable = true;
      onCalendar = "daily"; # Default value
    };
  };

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
        editor = "${getExe' pkgs.emacs29-pgtk "emacsclient"} -cq";
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
      extraConfig = {
        #        gpg.format = "ssh";
        #        "gpg \"ssh\"".program = "${getExe' pkgs._1password-gui "op-ssh-sign"}";
        #        commit.gpgsign = true;
      };
      aliases = {
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
}
