{
  pkgs,
  config,
  lib,
  inputs,
  ...
} @ args: let
  hasosConfig = builtins.hasAttr "osConfig" args;
  hostIs = name: hasosConfig && args.osConfig.networking.hostName == name;

  isMjolnir = hostIs "MJOLNIR-LINUX";
  isMorpheus = hostIs "MORPHEUS-LINUX";
  isDeusEx = hostIs "DEUSEX-LINUX";
  isWork = hostIs "ct-lt-2506-nixos";
in {
  imports = with inputs; [
    hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = let
    snappy-switcher = let
      inherit (inputs.snappy-switcher.packages.${pkgs.stdenv.hostPlatform.system}) default;
    in
      lib.getExe default;

    hyprshot = lib.getExe pkgs.hyprshot;
    brightnessctl = lib.getExe pkgs.brightnessctl;
    swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";

    lua = lib.generators.mkLuaInline;
    dsp = {
      exec = cmd: lua ''hl.dsp.exec_cmd("${cmd}")'';
      close = lua "hl.dsp.window.close()";
      exit = lua "hl.dsp.exit()";
      float = lua ''hl.dsp.window.float({ action = "toggle" })'';
      fullscreen = lua "hl.dsp.window.fullscreen()";
      pseudo = lua "hl.dsp.window.pseudo()";
      layout = msg: lua ''hl.dsp.layout("${msg}")'';
      focus = dir: lua ''hl.dsp.focus({ direction = "${dir}" })'';
      swap = dir: lua ''hl.dsp.window.swap({ direction = "${dir}" })'';
      toggleSpecial = name: lua ''hl.dsp.workspace.toggle_special("${name}")'';
      moveToSpecial = name: lua ''hl.dsp.window.move({ workspace = "special:${name}" })'';
      focusWorkspace = ws: lua ''hl.dsp.focus({ workspace = "${toString ws}" })'';
      moveToWorkspace = ws: lua ''hl.dsp.window.move({ workspace = "${toString ws}" })'';
      drag = lua "hl.dsp.window.drag()";
      resize = lua "hl.dsp.window.resize()";
      sendshortcut = mod: key: lua ''hl.dsp.send_shortcut({ mods = "${mod}", key = "${key}" })'';
      env = k: v: lua ''hl.env("${k}", "${v}")'';
    };

    bind = keys: dispatcher: {
      _args = [
        keys
        dispatcher
      ];
    };
    bindOpts = keys: dispatcher: opts: {
      _args = [
        keys
        dispatcher
        opts
      ];
    };

    # Drives both `general.layout` and the layout-specific binds below.
    layout = "master";

    layoutBinds =
      if layout == "master"
      then [
        (bind "SUPER + J" (dsp.layout "swapwithmaster"))
        (bind "SUPER + M" (dsp.layout "focusmaster"))
        (bind "SUPER + I" (dsp.layout "addmaster"))
        (bind "SUPER + D" (dsp.layout "removemaster"))
        (bind "SUPER + O" (dsp.layout "orientationnext"))
      ]
      else [
        (bind "SUPER + J" (dsp.layout "togglesplit"))
        (bind "SUPER + SHIFT + P" dsp.pseudo)
      ];

    workspaceBinds = lib.concatMap (
      i: let
        key = toString (lib.mod i 10);
      in [
        (bind "SUPER + ${key}" (dsp.focusWorkspace i))
        (bind "SUPER + SHIFT + ${key}" (dsp.moveToWorkspace i))
      ]
    ) (lib.range 1 10);
  in {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = true;
    xwayland.enable = true;
    configType = "lua";
    # plugins = let
    #  inherit (pkgs.stdenv.hostPlatform) system;
    # in with inputs; [
    #  split-monitor-workspaces.packages.${system}.split-monitor-workspaces
    # ];
    settings = {
      bind = let
        lock_cmd = lib.getExe (pkgs.writeShellScriptBin "lock-cmd" ''
          #!/usr/bin/env bash
          loginctl lock-session
        '');
      in
        [
          (bind "SUPER + RETURN" (dsp.exec "alacritty"))
          (bind "SUPER + P" (dsp.exec "wm-menu"))
          (bind "SUPER + L" (dsp.exec "${lock_cmd}"))

          # Window management
          (bind "SUPER + Q" dsp.close)
          (bind "SUPER + SHIFT + Q" dsp.exit)
          (bind "SUPER + CTRL + Q" (dsp.exec "hyprlock"))
          (bind "SUPER + V" dsp.float)
          (bind "SUPER + F" dsp.fullscreen)

          # Focus
          (bind "SUPER + left" (dsp.focus "left"))
          (bind "SUPER + right" (dsp.focus "right"))
          (bind "SUPER + up" (dsp.focus "up"))
          (bind "SUPER + down" (dsp.focus "down"))

          # Swap windows
          (bind "SUPER + SHIFT + left" (dsp.swap "left"))
          (bind "SUPER + SHIFT + right" (dsp.swap "right"))
          (bind "SUPER + SHIFT + up" (dsp.swap "up"))
          (bind "SUPER + SHIFT + down" (dsp.swap "down"))

          # Screenshots
          (bind "Print" (dsp.exec "${hyprshot} -m region --clipboard-only"))
          (bind "SHIFT + Print" (dsp.exec "${hyprshot} -m window --clipboard-only"))
          (bind "CTRL + Print" (dsp.exec "${hyprshot} -m output --clipboard-only"))
          (bind "SUPER + SHIFT + S" (dsp.exec "${hyprshot} -m region"))

          # Clipboard history / notifications
          (bind "SUPER + C" (dsp.exec "alacritty --class clipse -e ${pkgs.clipse}/bin/clipse"))
          (bind "SUPER + N" (dsp.exec "${swaync-client} -t -sw"))
          (bind "SUPER + SHIFT + N" (dsp.exec "${swaync-client} -d -sw"))

          (bind "XF86AudioPlay" (dsp.exec "${pkgs.playerctl}/bin/playerctl -a play-pause"))

          (bind "ALT + TAB" (dsp.exec "${snappy-switcher} next"))

          (bind "ALT + SHIFT + Tab" (dsp.exec "${snappy-switcher} prev"))

          # Volume keys
          (bindOpts "XF86AudioRaiseVolume" (dsp.exec "wpctl set-volume @ 5%+") {
            locked = true;
            repeating = true;
          })
          (bindOpts "XF86AudioLowerVolume" (dsp.exec "wpctl set-volume @ 5%-") {
            locked = true;
            repeating = true;
          })
          (bindOpts "XF86AudioMute" (dsp.exec "wpctl set-mute @ toggle") {locked = true;})
          (bindOpts "XF86AudioMicMute" (dsp.exec "wpctl set-mute u/DEFAULT_AUDIO_SOURCE@ toggle") {locked = true;})

          # Backlight keys
          (bindOpts "XF86MonBrightnessUp" (dsp.exec "${brightnessctl} -e4 -n2 set 5%+") {
            locked = true;
            repeating = true;
          })
          (bindOpts "XF86MonBrightnessDown" (dsp.exec "${brightnessctl} -e4 -n2 set 5%-") {
            locked = true;
            repeating = true;
          })

          # Mouse move/resize
          (bindOpts "SUPER + mouse:272" dsp.drag {mouse = true;})
          (bindOpts "SUPER + mouse:273" dsp.resize {mouse = true;})

          (bindOpts "switch:on:Lid Switch" (lua ''hl.dsp.dpms({ action = "off" })'') {locked = true;})
          (bindOpts "switch:off:Lid Switch" (lua ''hl.dsp.dpms({ action = "on" })'') {locked = true;})
        ]
        ++ layoutBinds
        ++ workspaceBinds;

      monitor = [
        {
          output = "WAYLAND-1";
          disabled = true;
        }
      ];

      config = {
        binds.drag_threshold = 10;
        general = {
          gaps_in = 2;
          gaps_out = 2;
          border_size = 2;
          inherit layout;
        };
        decoration = {
          rounding = 7;
          rounding_power = 4;
          active_opacity = 1;
          blur = {
            enabled = true;
            size = 8;
            passes = 3;
            noise = 0.01;
            contrast = 0.9;
            brightness = 0.8;
            popups = true;
          };
          shadow.enabled = true;
        };
        input = {
          follow_mouse = true;
          touchpad.natural_scroll = false;
          touchdevice.enabled = false;
          sensitivity = 0.5;
          kb_layout = "us";
        };
        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };
        animations.enabled = true;
        misc = {
          allow_session_lock_restore = true;
          anr_missed_pings = 10;
          disable_autoreload = false;
          disable_hyprland_guiutils_check = true;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          focus_on_activate = false;
          key_press_enables_dpms = true;
          lockdead_screen_delay = 5000;
          mouse_move_enables_dpms = false;
        };
        cursor = {
          no_hardware_cursors = true;
        };
        debug = {
          disable_scale_checks = true;
          vfr = true;
        };
        xwayland = {
          force_zero_scaling = true;
          enabled = true;
          use_nearest_neighbor = false;
        };
      };

      layer_rule = [
        {
          name = "blur-notifications";
          ignore_alpha = 0;
          blur = true;
          match.namespace = "notifications";
        }
      ];

      env = let
        toEnv = e: let
          p = lib.splitString "," e;
        in {
          _args = [(lib.head p) (lib.concatStringsSep "," (lib.tail p))];
        };
      in
        map toEnv
        ([
            "GDK_BACKEND,wayland"
            "GDK_SCALE,${
              if (isMorpheus || isDeusEx || isWork)
              then "1"
              else "2"
            }"
            "MOZ_ENABLE_WAYLAND,1"
            "QT_AUTO_SCREEN_SCALE_FACTOR,1"
            "QT_QPA_PLATFORM,wayland;xcb"
            "QT_ENABLE_HIGHDPI_SCALING,1"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "SDL_VIDEODRIVER,wayland"
            "XDG_SESSION_TYPE,wayland"
            "XCURSOR_SIZE,24"
            "HYPRCURSOR_SIZE,24"
            "_JAVA_AWT_WM_NONREPARENTING,1"
          ]
          ++ lib.optionals (isMjolnir || isWork) [
            "GBM_BACKEND,nvidia-drm"
            "LIBVA_DRIVER_NAME,iHD"
            "NVD_BACKEND,direct"
            "PROTON_ENABLE_NGX_UPDATER,1"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
            "__GL_MaxFramesAllowed,1"
            "__GL_VRR_ALLOWED,0"
            "__VK_LAYER_NV_optimus,NVIDIA_only"
          ]);

      window_rule = [
        {
          name = "fix-mpv-flickerng";
          match.class = "mpv";
          content = "none";
        }
        {
          name = "float-clipse";
          match.class = "clipse";
          float = true;
          size = "622 652";
        }
      ];

      on = {
        _args = let
          exec-once = pkgs.writeShellScriptBin "autostart" ''
            ${pkgs.bat}/bin/bat cache --build &
            ${pkgs.clipse}/bin/clipse -listen &
            ${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular &
            ${pkgs.xrdb}/bin/xrdb -merge $HOME/.Xresources &
            ${pkgs.sunsetr}/bin/sunsetr &
            ${snappy-switcher} --daemon &
            ${pkgs.iio-hyprland}/bin/iio-hyprland &

            wait $(jobs -p)
          '';
        in [
          "hyprland.start"
          (lua ''
            function()
              hl.exec_cmd("${lib.getExe exec-once}")
            end'')
        ];
      };
    };
  };

  services.hypridle = {
    enable = config.wayland.windowManager.hyprland.enable;
    settings = let
      mkDpms = x: "hl.dsp.dpms({ action = \"${x}\"})";
    in {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        on_lock_cmd = "swaync-client -dn && hyprctl dispatch '${mkDpms "off"}'";
        on_unlock_cmd = "swaync-client -df && hyprctl dispatch '${mkDpms "on"}'";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch '${mkDpms "on"}'";
      };
      listener = [
        {
          timeout = 150;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 290;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 310;
          on-timeout = "hyprctl dispatch '${mkDpms "off"}'";
          on-resume = "hyprctl dispatch '${mkDpms "on"}' && brightnessctl -r";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = config.services.hypridle.enable;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      animations = {
        enabled = true;
        fade_in = {
          duration = 300;
          bezier = "easeOutQuint";
        };
        fade_out = {
          duration = 300;
          bezier = "easeOutQuint";
        };
      };
      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "<span foreground=\"##cad3f5\">Password...</span>";
          shadow_passes = 2;
        }
      ];
    };
  };

  services.swaync.enable = true;

  services.wpaperd = {
    enable = true;
    settings = {
      default = {
        duration = "15m";
        sorting = "random";
      };
      any = {
        path = "${inputs.nixfigs-wallpapers}/wallpapers/";
      };
    };
  };

  services.hyprpaper = {
    enable = !config.services.wpaperd.enable;
    package = pkgs.hyprpaper;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "";
          path = "${inputs.nixfigs-wallpapers}/wallpapers/";
        }
      ];
    };
  };

  programs.hyprshot.enable = config.wayland.windowManager.hyprland.enable;
  services.hyprpolkitagent.enable = config.wayland.windowManager.hyprland.enable;

  programs.waybar = {
    enable = true;
    systemd.enable = config.programs.waybar.enable;
    style = import ./waybar-style.nix;
    settings.main = builtins.fromJSON (builtins.readFile ./waybar-config.json);
  };

  services.avizo.enable = true;
}
