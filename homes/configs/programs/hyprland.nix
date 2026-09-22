{
  pkgs,
  config,
  lib,
  inputs,
  ...
} @ args: let
  hasosConfig = builtins.hasAttr "osConfig" args;
  windowManager = args.osConfig.nixfigs.graphical.windowManagers.selectedWindowManager or "hyprland";
  # Build-time toggle for the hy3 plugin: set
  # `nixfigs.graphical.windowManagers.enableHy3 = true;` in the NixOS config
  # to opt in. Defaults to disabled (no plugin fetch/build, no hy3 binds).
  enableHy3 = args.osConfig.nixfigs.graphical.windowManagers.enableHy3 or false;
  hostIs = name: hasosConfig && args.osConfig ? config && args.osConfig.networking.hostName == name;

  isMjolnir = hostIs "MJOLNIR-LINUX";
  isFreyr = hostIs "FREYR-LINUX";
  isHeimdall = hostIs "HEIMDALL-LINUX";
  isWork = hostIs "ct-lt-2506-nixos";

  lockScripts = import ./session-lock.nix {
    inherit pkgs;
    hyprlockPackage = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;
  };
  lockPrep = lib.getExe lockScripts.lockPrep;
  unlockResume = lib.getExe lockScripts.unlockResume;
  wasScheduledWake = lib.getExe lockScripts.wasScheduledWake;
  hyprlockLaunch = lib.getExe lockScripts.hyprlockLaunch;
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

    # hy3 (i3/sway-like tabbed/tiling layout) is loaded as a Hyprland plugin
    # for the whole session whenever `enableHy3` is true, so which layout is
    # *active* (`general:layout`) can be flipped at runtime via `hyprctl`
    # without a NixOS/home-manager rebuild. `enableHy3` itself is a
    # build-time switch: disabling it drops the plugin (and its binds)
    # entirely, so it does require a rebuild to take effect.
    hy3Package = inputs.hy3.packages.${pkgs.stdenv.hostPlatform.system}.hy3;

    # `hl.plugin.hy3` is only populated once the hy3 plugin finishes loading
    # (asynchronously, after the config script's first pass), so these must
    # be deferred closures rather than plain expressions: `hl.bind` evaluates
    # its dispatcher argument eagerly while building the bind table, and
    # indexing `hl.plugin.hy3` at that point (before the plugin has
    # registered) is what throws "attempting to index a nil value (field
    # 'hy3')".
    hy3 = {
      makeTabGroup = lua ''function() hl.plugin.hy3.make_group("tab", { toggle = true }) end'';
      toggleTabbed = lua ''function() hl.plugin.hy3.change_group("toggletab") end'';
      focusTab = dir: lua ''function() hl.plugin.hy3.focus_tab({ direction = "${dir}", wrap = true }) end'';
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

    bindOpts = keys: dispatcher: opts: {
      _args = [
        keys
        dispatcher
        opts
      ];
    };

    # Renders every registered bind's `description` (see `bindOpts` calls
    # below) as a searchable rofi cheatsheet, sourced live from
    # `hyprctl binds -j` so it never drifts from what's actually bound.
    hyprBindsHelpScript = lib.getExe (pkgs.writeShellScriptBin "hypr-binds-help" ''
      #!/usr/bin/env bash
      set -euo pipefail
      hyprctl binds -j |
        ${lib.getExe pkgs.jq} -r 'def getbit($position; $n):
          fmod($n/($position|exp2)|floor;2) | fabs;

        def mod($position; $name):
            if getbit($position; .modmask) == 1 then $name + " + " else "" end;

        .[] | .description + "|" + mod(6; "SUPER") + mod(2; "Ctrl") + mod(3; "Alt") + mod(0; "Shift") + .key
        ' | ${lib.getExe' pkgs.util-linux "column"} -t -s "|" |
        rofi -dmenu -i -sync -p "Bind" -format e -case-smart -l 40 -theme-str "listview {columns: 4;}"
    '');

    # Drives the non-hy3 layout-specific binds below, and is the layout the
    # runtime toggle (`hy3ToggleScript`) falls back to when switching away
    # from hy3.
    layout = "master";

    # The layout Hyprland actually starts in. When hy3 is enabled,
    # `SUPER + SHIFT + T` toggles back to `layout` above at runtime; when
    # disabled at build-time, this falls back to the base `layout` outright.
    defaultLayout =
      if enableHy3
      then "hy3"
      else layout;

    layoutBinds =
      if layout == "master"
      then [
        (bindOpts "SUPER + J" (dsp.layout "swapwithmaster") {description = "master: swap the focused window with the master";})
        (bindOpts "SUPER + M" (dsp.layout "focusmaster") {description = "master: focus the master window";})
        (bindOpts "SUPER + I" (dsp.layout "addmaster") {description = "master: add the focused window to the master area";})
        (bindOpts "SUPER + D" (dsp.layout "removemaster") {description = "master: remove the focused window from the master area";})
        (bindOpts "SUPER + O" (dsp.layout "orientationnext") {description = "master: cycle the master area orientation";})
      ]
      else [
        (bindOpts "SUPER + J" (dsp.layout "togglesplit") {description = "dwindle: toggle the split orientation";})
        (bindOpts "SUPER + SHIFT + P" dsp.pseudo {description = "dwindle: toggle pseudotiling for the focused window";})
      ];

    # hy3-exclusive dispatchers (tab groups). These are always bound: they
    # only do something meaningful once `general:layout` is switched to hy3
    # (see `hy3ToggleScript`), and are harmless no-ops under master/dwindle.
    #
    # Each bind below carries a native `description`, so the full list with
    # explanations is queryable at runtime via `hyprctl binds`.
    #
    # Arrow-key focus/swap/move binds above are unchanged: Hyprland's core
    # movefocus/movewindow dispatchers work against any active layout,
    # including hy3, so they don't need hy3-specific replacements.
    hy3Binds = [
      (bindOpts "SUPER + SHIFT + T" (dsp.exec hy3ToggleScript) {
        description = "hy3: toggle the active layout between hy3 and master at runtime (no rebuild)";
      })
      (bindOpts "SUPER + T" hy3.makeTabGroup {
        description = "hy3: turn the focused node into a tab group, or dissolve it back out";
      })
      (bindOpts "SUPER + SHIFT + G" hy3.toggleTabbed {
        description = "hy3: toggle tabbed layout on the focused node's group";
      })
      (bindOpts "SUPER + bracketleft" (hy3.focusTab "l") {
        description = "hy3: focus the previous tab in the group";
      })
      (bindOpts "SUPER + bracketright" (hy3.focusTab "r") {
        description = "hy3: focus the next tab in the group";
      })
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
          (bindOpts "SUPER + ${key}" (splitWorkspace i) {description = "Focus workspace ${toString i} on the active monitor";})
          (bindOpts "SUPER + SHIFT + ${key}" (splitMoveToWorkspace i) {description = "Move the focused window to workspace ${toString i} on the active monitor";})
        ]
        else [
          (bindOpts "SUPER + ${key}" (dsp.focusWorkspace i) {description = "Focus workspace ${toString i}";})
          (bindOpts "SUPER + SHIFT + ${key}" (dsp.moveToWorkspace i) {description = "Move the focused window to workspace ${toString i}";})
        ]
    ) (lib.range 1 10);
  in {
    enable = windowManager == "hyprland";
    package = null;
    portalPackage = null;
    systemd.enable = true;
    xwayland.enable = true;
    configType = "lua";
    plugins = lib.optionals enableHy3 [hy3Package];
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

      -- On `monitor.removed`, split-monitor-workspaces only unmaps the
      -- departed monitor's own workspace range; it doesn't recompute a
      -- contiguous mapping across the monitors that remain (that only
      -- happens on `config.reloaded`, via monitors.remap_all_monitors()).
      -- Left alone, the surviving monitor(s) would keep showing gappy,
      -- out-of-order workspace numbers instead of a clean 1..N layout.
      --
      -- Force a config reload here so smw's own `config.reloaded` handler
      -- runs and remaps everything, instead of reaching into its internal
      -- (non-public) API ourselves.
      hl.on("monitor.removed", function()
        hl.exec_cmd("hyprctl reload")
      end)
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
          (bindOpts "SUPER + RETURN" (dsp.exec "${lib.getExe pkgs.alacritty}") {description = "Open a terminal (Alacritty)";})
          (bindOpts "SUPER + P" (dsp.exec "${lib.getExe pkgs.wm-menu}") {description = "Open the application launcher";})
          (bindOpts "SUPER + L" (dsp.exec "${lock_cmd}") {description = "Lock the session";})
          (bindOpts "SUPER + H" (dsp.exec hyprBindsHelpScript) {description = "Show all keybindings (rofi cheatsheet)";})

          # Window management
          (bindOpts "SUPER + Q" dsp.close {description = "Close the focused window";})
          (bindOpts "SUPER + SHIFT + Q" dsp.exit {description = "Exit Hyprland";})
          (bindOpts "SUPER + V" dsp.float {description = "Toggle floating for the focused window";})
          (bindOpts "SUPER + F" dsp.fullscreen {description = "Toggle fullscreen for the focused window";})

          # Focus
          (bindOpts "SUPER + down" (dsp.focus "down") {description = "Focus the window below";})
          (bindOpts "SUPER + left" (dsp.focus "left") {description = "Focus the window to the left";})
          (bindOpts "SUPER + right" (dsp.focus "right") {description = "Focus the window to the right";})
          (bindOpts "SUPER + up" (dsp.focus "up") {description = "Focus the window above";})

          # Swap windows
          (bindOpts "SUPER + CTRL + down" (dsp.swap "down") {description = "Swap the focused window with the one below";})
          (bindOpts "SUPER + CTRL + left" (dsp.swap "left") {description = "Swap the focused window with the one to the left";})
          (bindOpts "SUPER + CTRL + right" (dsp.swap "right") {description = "Swap the focused window with the one to the right";})
          (bindOpts "SUPER + CTRL + up" (dsp.swap "up") {description = "Swap the focused window with the one above";})

          # Move active window to another monitor in the given direction.
          # `silent` keeps focus on the source monitor.
          (bindOpts "SUPER + SHIFT + down" (dsp.moveToDirection "down") {description = "Move the focused window to the monitor below";})
          (bindOpts "SUPER + SHIFT + left" (dsp.moveToDirection "left") {description = "Move the focused window to the monitor on the left";})
          (bindOpts "SUPER + SHIFT + right" (dsp.moveToDirection "right") {description = "Move the focused window to the monitor on the right";})
          (bindOpts "SUPER + SHIFT + up" (dsp.moveToDirection "up") {description = "Move the focused window to the monitor above";})

          # Screenshots
          (bindOpts "Print" (dsp.exec "${hyprshot} -m region --clipboard-only") {description = "Screenshot a region to the clipboard";})
          (bindOpts "SHIFT + Print" (dsp.exec "${hyprshot} -m window --clipboard-only") {description = "Screenshot the focused window to the clipboard";})
          (bindOpts "CTRL + Print" (dsp.exec "${hyprshot} -m output --clipboard-only") {description = "Screenshot the focused output to the clipboard";})
          (bindOpts "SUPER + SHIFT + Print" (dsp.exec "${hyprshot} -m region") {description = "Screenshot a region to a file";})

          # Clipboard history / notifications
          (bindOpts "SUPER + C" (dsp.exec "alacritty --class clipse -e ${pkgs.clipse}/bin/clipse") {description = "Open clipboard history";})
          (bindOpts "SUPER + N" (dsp.exec "${swaync-client} -t -sw") {description = "Toggle the notification center";})
          (bindOpts "SUPER + SHIFT + N" (dsp.exec "${swaync-client} -d -sw") {description = "Toggle do-not-disturb";})

          (bindOpts "XF86AudioPlay" (dsp.exec "${pkgs.playerctl}/bin/playerctl -a play-pause") {description = "Play/pause media";})

          (bindOpts "ALT + TAB" (dsp.exec "${snappy-switcher} next") {description = "Switch to the next window";})

          (bindOpts "ALT + SHIFT + Tab" (dsp.exec "${snappy-switcher} prev") {description = "Switch to the previous window";})

          # Volume keys
          (bindOpts "XF86AudioRaiseVolume" (dsp.exec "wpctl set-volume @ 5%+") {
            locked = true;
            repeating = true;
            description = "Raise volume by 5%";
          })
          (bindOpts "XF86AudioLowerVolume" (dsp.exec "wpctl set-volume @ 5%-") {
            locked = true;
            repeating = true;
            description = "Lower volume by 5%";
          })
          (bindOpts "XF86AudioMute" (dsp.exec "wpctl set-mute @ toggle") {
            locked = true;
            description = "Toggle mute";
          })
          (bindOpts "XF86AudioMicMute" (dsp.exec "wpctl set-mute u/DEFAULT_AUDIO_SOURCE@ toggle") {
            locked = true;
            description = "Toggle microphone mute";
          })

          # Backlight keys
          (bindOpts "XF86MonBrightnessUp" (dsp.exec "${brightnessctl} -e4 -n2 set 5%+") {
            locked = true;
            repeating = true;
            description = "Raise screen brightness by 5%";
          })
          (bindOpts "XF86MonBrightnessDown" (dsp.exec "${brightnessctl} -e4 -n2 set 5%-") {
            locked = true;
            repeating = true;
            description = "Lower screen brightness by 5%";
          })

          # Mouse move/resize
          (bindOpts "SUPER + mouse:272" dsp.drag {
            mouse = true;
            description = "Drag-move the focused window with the mouse";
          })
          (bindOpts "SUPER + mouse:273" dsp.resize {
            mouse = true;
            description = "Resize the focused window with the mouse";
          })

          (bindOpts "switch:on:Lid Switch" (lua ''hl.dsp.dpms({ action = "off" })'') {
            locked = true;
            description = "Turn the screen off when the laptop lid closes";
          })
          (bindOpts "switch:off:Lid Switch" (lua ''hl.dsp.dpms({ action = "on" })'') {
            locked = true;
            description = "Turn the screen on when the laptop lid opens";
          })
        ]
        ++ layoutBinds
        ++ workspaceBinds
        ++ lib.optionals enableHy3 hy3Binds;

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
              if (isFreyr || isHeimdall || isWork)
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
      hyprlandConfigType = config.wayland.windowManager.hyprland.configType;
      hyprlandVersion =
        if hasosConfig
        then args.osConfig.programs.hyprland.package.version or null
        else null;
      # `configType` ("hyprlang" vs "lua") is slated for removal in
      # Hyprland v0.57.0, once hyprlang config support is dropped entirely
      # and `hyprctl dispatch` always evaluates its argument as Lua. Until
      # then, the two config engines need different DPMS dispatch syntax:
      # the classic `dpms <on|off>` string for hyprlang, or the
      # `hl.dsp.dpms({ action = ... })` helper for Lua — even when invoked
      # from a plain shell (e.g. these hypridle callbacks) rather than from
      # inside Hyprland's own config. See
      # https://github.com/hyprwm/Hyprland/discussions/14255.
      mkDpms = x:
        assert lib.assertMsg (x == "on" || x == "off")
        "mkDpms: `x` must be \"on\" or \"off\", got \"${x}\"";
          lib.warnIf (hyprlandVersion != null && lib.versionAtLeast hyprlandVersion "0.57.0")
          "mkDpms: Hyprland ${hyprlandVersion} has removed `configType`; drop the hyprlang branch and the configType/hyprlandVersion plumbing from mkDpms"
          (
            if hyprlandConfigType == "hyprlang"
            then "dpms ${x}"
            else "hl.dsp.dpms({ action = \"${x}\" })"
          );
    in {
      general = {
        # Let media players (Firefox, mpv, Steam) hold off the idle timers.
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
        lock_cmd = hyprlockLaunch;
        # `|| true` after swaync-client: swaync isn't guaranteed to be up
        # (or installed) on every session, and a failed DND toggle shouldn't
        # abort the rest of the lock/unlock chain.
        on_lock_cmd = "${lockPrep} && (swaync-client -dn || true) && hyprctl dispatch '${mkDpms "off"}'";
        on_unlock_cmd = "${unlockResume} && (swaync-client -df || true) && hyprctl dispatch '${mkDpms "on"}'";
        before_sleep_cmd = "loginctl lock-session";
        # hypridle's idle listener timers aren't suspend-aware and don't
        # reset across a sleep cycle (see hyprwm/hypridle #73, #178), so a
        # listener that already fired pre-suspend (e.g. the 90s lock-screen
        # re-blank below) never re-arms after resume. Restarting the
        # service gives every listener a clean slate; backgrounding it
        # avoids killing the shell mid-restart since systemctl hands the
        # request straight to systemd.
        # Skip forcing the display back on when the machine was woken by an
        # unattended RTC timer (see `wasScheduledWake`) -- nobody is there to
        # look at it, so turning it on just leaves it lit until the next
        # idle cycle catches up.
        after_sleep_cmd = "${wasScheduledWake} || hyprctl dispatch '${mkDpms "on"}'; (systemctl --user restart hypridle.service &disown)";
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
        {
          # Hyprland wakes the monitor on any input while hyprlock is up
          # (e.g. typing a password), even with DPMS off. This re-blanks
          # the screen after 90s of no further interaction with the lock
          # screen, independent of the pre-lock idle chain above.
          timeout = 90;
          on-timeout = "pidof hyprlock && hyprctl dispatch '${mkDpms "off"}'";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = config.services.hypridle.enable;
    # See the `hyprlock` flake input: stock hyprlock SIGABRTs the instant it
    # loses its Wayland connection to Hyprland (shutdown, DPMS power-cycling
    # a monitor, hotplugging a display -- hyprwm/hyprlock #991), instead of
    # exiting cleanly. This is built from the unmerged upstream fix
    # (hyprwm/hyprlock #1052) so it doesn't abort in the first place.
    # `hyprlock-shutdown-guard` and `hyprlock-watchdog` below are additional
    # layers on top, not a replacement: even a clean `exit(1)` on connection
    # loss leaves the session locked with no locker UI ("oopsie daisy") until
    # something relaunches hyprlock.
    package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      # None of these hosts have a fingerprint reader, but hyprlock's
      # fingerprint auth backend is on by default and, once enabled, opens a
      # system D-Bus connection whose fd it polls in the main event loop
      # alongside the Wayland fd -- one more fd that can POLLHUP and (on
      # stock hyprlock) abort it. Not load-bearing now that `package` above
      # is built from the graceful-disconnect fix, but there's no reason to
      # keep an unused dbus connection open either.
      auth.fingerprint.enabled = false;

      animations.enabled = true;
      bezier = ["easeOutQuint, 0.23, 1, 0.32, 1"];
      animation = [
        "fadeIn, 1, 3, easeOutQuint"
        "fadeOut, 1, 3, easeOutQuint"
      ];
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

  # Belt-and-suspenders on top of the graceful-disconnect fix baked into
  # `programs.hyprlock.package` above: proactively SIGUSR1s hyprlock (its
  # documented graceful-unlock signal) the moment logind announces a
  # shutdown, so it exits cleanly *before* Hyprland's socket disappears
  # instead of racing the teardown at all. Holds a `shutdown`
  # delay-inhibitor so systemd-logind blocks poweroff/reboot just long
  # enough for this to happen.
  systemd.user.services.hyprlock-shutdown-guard = lib.mkIf config.programs.hyprlock.enable {
    Unit = {
      Description = "SIGUSR1 hyprlock before shutdown so it exits cleanly instead of racing the teardown";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = lib.getExe (pkgs.writeShellScriptBin "hyprlock-shutdown-guard" ''
        set -euo pipefail
        while true; do
          ${pkgs.systemd}/bin/systemd-inhibit --what=shutdown --mode=delay \
            --who="hyprlock-shutdown-guard" \
            --why="let hyprlock exit cleanly before Hyprland's Wayland socket disappears" \
            ${lib.getExe pkgs.bash} -c '
              ${pkgs.glib}/bin/gdbus monitor --system --dest org.freedesktop.login1 \
                --object-path /org/freedesktop/login1 2>/dev/null |
                grep -qm1 "PrepareForShutdown"
              ${pkgs.procps}/bin/pkill -SIGUSR1 -x hyprlock || true
            '
        done
      '');
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  # Second safety net: even with the graceful-disconnect fix, a hyprlock
  # that exits (cleanly or otherwise) while the session is still locked
  # leaves ext-session-lock active with no locker UI to type a password
  # into -- Hyprland's "oopsie daisy" screen. Poll for that specific state
  # (locked per logind, but no hyprlock process) and relaunch it, so a
  # crash anywhere this doesn't otherwise catch (e.g. a future regression,
  # or a completely different abort) still self-heals instead of requiring
  # a manual restart.
  #
  # Relaunches go through `hyprlockLaunch` (session-lock.nix), which
  # serializes against hypridle's own `lock_cmd` so this poll can never
  # spawn a duplicate hyprlock racing another for the ext-session-lock-v1
  # grab. That race used to hot-loop this watchdog every 3s indefinitely
  # once ext-session-lock-v1 got stuck refusing new clients (146 failed
  # "Couldn't bind" attempts in 8 minutes, observed 2026-09-18 -- the
  # SIGABRT itself was already fixed by 969a231, this was a second bug in
  # the recovery path). The backoff below is a second layer on top: if a
  # relaunch attempt doesn't leave hyprlock running a second later (e.g.
  # ext-session-lock-v1 itself is refusing binds, which flock can't fix),
  # back off up to 30s between attempts instead of hammering it.
  systemd.user.services.hyprlock-watchdog = lib.mkIf config.programs.hyprlock.enable {
    Unit = {
      Description = "Relaunch hyprlock if it dies while the session is still locked";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = lib.getExe (pkgs.writeShellScriptBin "hyprlock-watchdog" ''
        set -euo pipefail
        backoff=3
        while true; do
          sleep "$backoff"
          locked="$(${pkgs.systemd}/bin/loginctl show-session "''${XDG_SESSION_ID:-}" -p LockedHint --value 2>/dev/null || true)"
          if [ "$locked" = "yes" ] && ! ${pkgs.procps}/bin/pidof hyprlock >/dev/null 2>&1; then
            ${hyprlockLaunch} &
            disown
            sleep 1
            if ${pkgs.procps}/bin/pidof hyprlock >/dev/null 2>&1; then
              backoff=3
            else
              backoff=$(( backoff < 30 ? backoff * 2 : 30 ))
            fi
          else
            backoff=3
          fi
        done
      '');
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = ["graphical-session.target"];
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
  services.hyprpolkitagent.enable = windowManager == "hyprland" || windowManager == "sway";

  programs.waybar = {
    enable = windowManager == "hyprland" || windowManager == "sway";
    systemd.enable = config.programs.waybar.enable;
    style = import ./waybar-style.nix;
    settings.main = builtins.fromJSON (builtins.readFile ./waybar-config.json);
  };

  services.avizo.enable = true;
}
