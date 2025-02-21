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
  getHomeDirectory = username: homePrefix + "/${username}";
  homeDirectory = getHomeDirectory username;
  flatpakPackages = [
    "app.ytmdesktop.ytmdesktop"
    "chat.delta.desktop"
    "com.atlauncher.ATLauncher"
    "com.calibre_ebook.calibre"
    "com.discordapp.Discord"
    "com.freerdp.FreeRDP"
    "com.getpostman.Postman"
    "com.github.IsmaelMartinez.teams_for_linux"
    "com.github.Matoking.protontricks"
    "com.github.tchx84.Flatseal"
    "com.icanblink.blink"
    "com.jgraph.drawio.desktop"
    "com.meetfranz.Franz"
    "com.moonlight_stream.Moonlight"
    "com.prusa3d.PrusaSlicer"
    "com.slack.Slack"
    "com.usebottles.bottles"
    "com.valvesoftware.Steam"
    "com.valvesoftware.SteamLink"
    "com.wps.Office"
    "dev.zed.Zed"
    "im.fluffychat.Fluffychat"
    "im.riot.Riot"
    "io.dbeaver.DBeaverCommunity"
    "net.ankiweb.Anki"
    "net.kuribo64.melonDS"
    "net.lutris.Lutris"
    "net.minetest.Minetest"
    "net.redeclip.redclip"
    "org.DolphinEmu.dolphin-emu"
    "org.blender.Blender"
    "org.citra_emu.citra"
    "org.dust3d.dust3d"
    "org.filezillaproject.Filezilla"
    "org.freecadweb.FreeCAD"
    "org.fritzing.Fritzing"
    "org.gnome.Boxes"
    "org.gnome.Calls"
    "org.gnome.Evolution"
    "org.gnome.NetworkDisplays"
    "org.jitsi.jitsi-meet"
    "org.kicad.KiCad"
    "org.libreoffice.LibreOffice"
    "org.mozilla.Thunderbird"
    "org.onlyoffice.desktopeditors"
    "org.openscad.OpenSCAD"
    "org.prismlauncher.PrismLauncher"
    "org.remmina.Remmina"
    "org.telegram.desktop"
    "org.yuzu_emu.yuzu"
    "org.zdoom.GZDoom"
    "us.zoom.Zoom"
  ];
in {
  imports =
    [
      ./network-targets.nix
      (import ./programs/rofi.nix {inherit lib pkgs;})
      inputs.agenix.homeManagerModules.default
      inputs.nix-doom-emacs-unstraightened.hmModule
      inputs.nix-index-database.hmModules.nix-index
      inputs._1password-shell-plugins.hmModules.default
      inputs.shypkgs-public.hmModules.${system}.dwl
      inputs.nix-flatpak.homeManagerModules.nix-flatpak
      inputs.nixfigs-secrets.user
      inputs.lix-module.nixosModules.default
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
          "https://cache.dataaturservice.se/spectrum/?priority=50"
          "https://cache.nixos.org/?priority=10"
          "https://deploy-rs.cachix.org/?priority=10"
          "https://devenv.cachix.org/?priority=5"
          "https://nix-community.cachix.org/?priority=5"
          "https://nix-gaming.cachix.org/?priority=5"
          "https://nix-on-droid.cachix.org/?priority=5"
          "https://numtide.cachix.org/?priority=5"
          "https://pre-commit-hooks.cachix.org/?priority=5"
          "ssh://eu.nixbuild.net?priority=50"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
          "nixbuild.net/VNUM6K-1:ha1G8guB68/E1npRiatdXfLZfoFBddJ5b2fPt3R9JqU="
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
          "spectrum-os.org-2:foQk3r7t2VpRx92CaXb5ROyy/NBdRJQG2uX2XJMYZfU="
        ];
        binary-caches = substituters;
        builders-use-substitutes = true;
        http-connections = 128;
        max-substitution-jobs = 128;
      };
      registry = rec {
        nixpkgs.flake = inputs.nixpkgs;
        n.flake = nixpkgs.flake;
        home-manager.flake = inputs.home-manager;
        unstable.flake = inputs.nixpkgs-unstable;
        shynixpkgs.flake = inputs.nixpkgs-shymega;
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
    packages = with pkgs.unstable;
      [
        aerc
        age
        alpaca
        alsa-utils
        android-tools
        asciinema
        aws-sam-cli
        azure-cli
        b4
        bat
        bc
        beeper
        brightnessctl
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
        gh
        glab
        gnumake
        google-chrome
        google-cloud-sdk
        gthumb
        httpie
        hub
        hut
        imagemagick
        inetutils
        ispell
        itd
        jdk17
        jq
        khal
        khard
        leafnode
        llm-ls
        m4
        maven
        meli
        mkcert
        moneydance
        mpc-cli
        mupdf
        ncmpcpp
        neomutt
        networkmanagerapplet
        nh
        nixpkgs-fmt
        nodejs
        notmuch
        p7zip
        parallel
        pass
        pavucontrol
        pdftk
        pizauth
        playerctl
        pmbootstrap-bumped
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
        ripgrep
        rustup
        scrcpy
        speedtest-go
        starship
        statix
        stow
        swaks
        tea
        tigervnc
        timewarrior
        tmuxp
        unrar
        unzip
        vdirsyncer
        w3m
        wayfarer
        wayvnc
        weechatWithMyPlugins
        wezterm
        wf-recorder
        wget
        wl-mirror
        xsv
        yubikey-manager-qt
        zathura
        zellij
        zip
        zoxide
      ]
      ++ [inputs.agenix.packages.${system}.default]
      ++ [(pkgs.isync.override {withCyrusSaslXoauth2 = true;})]
      ++ (
        with pkgs;
          lib.optionals isPC (
            with pkgs.unstable.jetbrains; [
              clion
              datagrip
              gateway
              goland
              idea-ultimate
              phpstorm
              pycharm-professional
              rider
              ruby-mine
              rust-rover
              webstorm
              writerside
            ]
          )
      )
      ++ (
        with pkgs;
          lib.optionals isPC [
            android-studio
            android-studio-for-platform
            bestool
            buildbox
            buildstream2
            deckcheatz
            libnotify
            mpv
            offlineimap
            protontricks
            protonup-qt
            steamcmd
            step-cli
            texlive.combined.scheme-full
            totp
            virt-manager
            virtiofsd
            vlc
            wemod-launcher
            wineWowPackages.stable
            winetricks
            wm-menu
            xrlinuxdriver
            zenmonitor
          ]
      );
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
    enable = true;
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
    nix-index-database.comma.enable = false;
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
        #        "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
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
    doom-emacs = {
      enable = false;
      emacs = pkgs.emacs29-pgtk;
      provideEmacs = true;
      experimentalFetchTree = true;
      doomDir = inputs.nixfigs-doom-emacs;
      doomLocalDir = "${homeDirectory}/.local/state/doom";
    };
    taskwarrior = {
      enable = true;
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
          ExecStart = "${lib.getExe' pkgs.unstable.atuin "atuin"} daemon";
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
          After = ["graphical-session.target"];
        };
        Install.WantedBy = ["graphical-session.target"];
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
          ExecStartPre = "${getExe' pkgs.taskwarrior "task"}";
          ExecStart = "${getExe' pkgs.taskwarrior "task"} sync";
          ExecStartPost = "${getExe' pkgs.taskwarrior "task"} sync";
        };
      };
    };
  };
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}
