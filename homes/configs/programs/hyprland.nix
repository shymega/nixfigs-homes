{
  pkgs,
  config,
  lib,
  inputs,
  ...
} @ args: let
  hasosConfig = builtins.hasAttr "osConfig" args;
  windowManager = args.osConfig.nixfigs.graphical.windowManagers.selectedWindowManager or "hyprland";
  hostIs = name: hasosConfig && args.osConfig ? config && args.osConfig.networking.hostName == name;

  isMjolnir = hostIs "MJOLNIR-LINUX";
  isMorpheus = hostIs "MORPHEUS-LINUX";
  isDeusEx = hostIs "DEUSEX-LINUX";
  isWork = hostIs "ct-lt-2506-nixos";

  lockScripts = import ./session-lock.nix {inherit pkgs;};
  lockPrep = lib.getExe lockScripts.lockPrep;
  unlockResume = lib.getExe lockScripts.unlockResume;
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
      moveToDirection = dir: lua ''hl.dsp.window.move({ direction = "${dir}" })'';
      drag = lua "hl.dsp.window.drag()";
      resize = lua "hl.dsp.window.resize()";
      sendshortcut = mod: key: lua ''hl.dsp.send_shortcut({ mods = "${mod}", key = "${key}" })'';
      env = k: v: lua ''hl.env("${k}", "${v}")'';
    };

    # Toggle between the `split-monitor-workspaces` plugin (per-monitor
    # workspaces) and Hyprland's stock, shared-workspace management.
    useSplitMonitorWorkspaces = true;

    # The `split-monitor-workspaces` Lua library exposes `smw.workspace` /
    # `smw.move_to_workspace` as closures compatible with `hl.bind`, so call
    # into it directly instead of shelling out to `hyprctl dispatch`.
    splitWorkspace = ws: lua ''smw.workspace("${toString ws}")'';
    splitMoveToWorkspace = ws: lua ''smw.move_to_workspace("${toString ws}")'';

    # hy3 (i3/sway-like tabbed/tiling layout) is always loaded as a Hyprland
    # plugin so it's available for the whole session; which layout is
    # *active* (`general:layout`) is then flipped at runtime via `hyprctl`,
    # so switching to/from hy3 never needs a NixOS/home-manager rebuild.
    hy3Package = inputs.hy3.packages.${pkgs.stdenv.hostPlatform.system}.hy3;

    hy3 = {
      makeTabGroup = lua ''hl.plugin.hy3.make_group("tab", { toggle = true })'';
      toggleTabbed = lua ''hl.plugin.hy3.change_group("toggletab")'';
      focusTab = dir: lua ''hl.plugin.hy3.focus_tab({ direction = "${dir}", wrap = true })'';
    };

    # Toggles `general:layout` between hy3 and the statically-configured
    # base `layout` (master/dwindle) via `hyprctl keyword`, so the active
    # layout can be switched at runtime without touching the Nix config.
    hy3ToggleScript = lib.getExe (pkgs.writeShellScriptBin "hypr-toggle-hy3" ''
      #!/usr/bin/env bash
      set -euo pipefail
      current="$(hyprctl getoption general:layout -j | ${lib.getExe pkgs.jq} -r '.str')"
      if [ "$current" = "hy3" ]; then
        hyprctl keyword general:layout "${layout}"
      else
        hyprctl keyword general:layout hy3
      fi
    '');

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

    # Drives the non-hy3 layout-specific binds below, and is the layout the
    # runtime toggle (`hy3ToggleScript`) falls back to when switching away
    # from hy3.
    layout = "master";

    # The layout Hyprland actually starts in. hy3 is the default for now;
    # `SUPER + SHIFT + T` toggles back to `layout` above at runtime.
    defaultLayout = "hy3";

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

    # hy3-exclusive dispatchers (tab groups). These are always bound: they
    # only do something meaningful once `general:layout` is switched to hy3
    # (see `hy3ToggleScript`), and are harmless no-ops under master/dwindle.
    #
    # Keybindings:
    #   SUPER + SHIFT + T         Toggle the active layout between hy3 and
    #                             `layout` (master) at runtime, via
    #                             `hyprctl keyword general:layout`. No
    #                             rebuild required.
    #   SUPER + T                 Turn the focused node into a tab group, or
    #                             dissolve it back out if it already is one
    #                             (`hy3:makegroup tab, toggle`).
    #   SUPER + SHIFT + G         Toggle tabbed layout on the focused node's
    #                             group without changing its membership
    #                             (`hy3:changegroup toggletab`).
    #   SUPER + bracketleft  ([)  Focus the previous tab in the group.
    #   SUPER + bracketright (]) Focus the next tab in the group.
    #
    # Arrow-key focus/swap/move binds above are unchanged: Hyprland's core
    # movefocus/movewindow dispatchers work against any active layout,
    # including hy3, so they don't need hy3-specific replacements.
    hy3Binds = [
      (bind "SUPER + SHIFT + T" (dsp.exec hy3ToggleScript))
      (bind "SUPER + T" hy3.makeTabGroup)
      (bind "SUPER + SHIFT + G" hy3.toggleTabbed)
      (bind "SUPER + bracketleft" (hy3.focusTab "l"))
      (bind "SUPER + bracketright" (hy3.focusTab "r"))
    ];

    toWorkspaceKey = n:
      if n == 10
      then "0"
      else toString n;

    workspaceBinds = lib.concatMap (
      i: let
        key = toWorkspaceKey i;
      in
        if useSplitMonitorWorkspaces
        then [
          (bind "SUPER + ${key}" (splitWorkspace i))
          (bind "SUPER + SHIFT + ${key}" (splitMoveToWorkspace i))
        ]
        else [
          (bind "SUPER + ${key}" (dsp.focusWorkspace i))
          (bind "SUPER + SHIFT + ${key}" (dsp.moveToWorkspace i))
        ]
    ) (lib.range 1 10);
  in {
    enable = windowManager == "hyprland";
    package = null;
    portalPackage = null;
    systemd.enable = true;
    xwayland.enable = true;
    configType = "lua";
    plugins = [hy3Package];
    extraConfig = lib.optionalString useSplitMonitorWorkspaces ''
      smw.setup({
        workspace_count = 10,
        keep_focused = true,
        enable_notifications = false,
        -- Don't pre-create empty workspaces: keeps the waybar workspaces
        -- module showing only workspaces that actually have windows (plus
        -- the currently focused one).
        enable_persistent_workspaces = false,
        enable_wrapping = true,
      })
    '';
    settings = {
      smw = lib.optionalAttrs useSplitMonitorWorkspaces {
        _var = lua ''
          (function()
            package.path = package.path .. ";${inputs.split-monitor-workspaces}/lua/?.lua"
            return require("split-monitor-workspaces")
          end)()'';
      };
      bind = let
        lock_cmd = lib.getExe (pkgs.writeShellScriptBin "lock-cmd" ''
          #!/usr/bin/env bash
          loginctl lock-session
        '');
      in
        [
          (bind "SUPER + RETURN" (dsp.exec "${lib.getExe pkgs.alacritty}"))
          (bind "SUPER + P" (dsp.exec "${lib.getExe pkgs.wm-menu}"))
          (bind "SUPER + L" (dsp.exec "${lock_cmd}"))

          # Window management
          (bind "SUPER + Q" dsp.close)
          (bind "SUPER + SHIFT + Q" dsp.exit)
          (bind "SUPER + V" dsp.float)
          (bind "SUPER + F" dsp.fullscreen)

          # Focus
          (bind "SUPER + down" (dsp.focus "down"))
          (bind "SUPER + left" (dsp.focus "left"))
          (bind "SUPER + right" (dsp.focus "right"))
          (bind "SUPER + up" (dsp.focus "up"))

          # Swap windows
          (bind "SUPER + CTRL + down" (dsp.swap "down"))
          (bind "SUPER + CTRL + left" (dsp.swap "left"))
          (bind "SUPER + CTRL + right" (dsp.swap "right"))
          (bind "SUPER + CTRL + up" (dsp.swap "up"))

          # Move active window to another monitor in the given direction.
          # `silent` keeps focus on the source monitor.
          (bind "SUPER + SHIFT + down" (dsp.moveToDirection "down"))
          (bind "SUPER + SHIFT + left" (dsp.moveToDirection "left"))
          (bind "SUPER + SHIFT + right" (dsp.moveToDirection "right"))
          (bind "SUPER + SHIFT + up" (dsp.moveToDirection "up"))

          # Screenshots
          (bind "Print" (dsp.exec "${hyprshot} -m region --clipboard-only"))
          (bind "SHIFT + Print" (dsp.exec "${hyprshot} -m window --clipboard-only"))
          (bind "CTRL + Print" (dsp.exec "${hyprshot} -m output --clipboard-only"))
          (bind "SUPER + SHIFT + Print" (dsp.exec "${hyprshot} -m region"))

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
        ++ workspaceBinds
        ++ hy3Binds;

      mod = {
        _var = "SUPER";
      };

      shiftMod = {
        _var = "SUPER + SHIFT";
      };

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
          layout = defaultLayout;
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
          follow_mouse = 1;
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
        # Let media players (Firefox, mpv, Steam) hold off the idle timers.
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
        lock_cmd = "pidof hyprlock || hyprlock";
        on_lock_cmd = "${lockPrep} && swaync-client -dn && hyprctl dispatch '${mkDpms "off"}'";
        on_unlock_cmd = "${unlockResume} && swaync-client -df && hyprctl dispatch '${mkDpms "on"}'";
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

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 64;
          font_family = "sans-serif";
          color = "rgb(202, 211, 245)";
          position = "0, 160";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
        }
        {
          monitor = "";
          text = "cmd[update:3600000] date +'%A, %d %B'";
          font_size = 20;
          font_family = "sans-serif";
          color = "rgb(202, 211, 245)";
          position = "0, 90";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
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
