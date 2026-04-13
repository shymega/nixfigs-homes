{
  pkgs,
  lib,
  inputs,
  ...
} @ args: let
  lock_cmd = pkgs.writeShellScriptBin "lock-cmd" ''
    #!/usr/bin/env bash
    loginctl lock-session
  '';
  hasosConfig = builtins.hasAttr "osConfig" args;
  isMjolnir =
    if hasosConfig
    then args.osConfig.networking.hostName == "MJOLNIR-LINUX"
    else false;
  isWork =
    if hasosConfig
    then args.osConfig.networking.hostName == "ct-lt-2506-nixos"
    else false;
in {
  imports = with inputs; [
    hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = let
    inherit (pkgs.stdenv.hostPlatform) system;
    snappy-switcher = lib.getExe inputs.snappy-switcher.packages.${system}.default;
    portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
  in {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = true;
    xwayland.enable = true;
    plugins = with inputs; [
      split-monitor-workspaces.packages.${system}.split-monitor-workspaces
    ];
    settings = {
      bind = [
        "$mainMod, Return, exec, alacritty"

        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, V, togglefloating,"
        "$mainMod, P, exec, wm-menu"

        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, split-workspace, 1"
        "$mainMod, 2, split-workspace, 2"
        "$mainMod, 3, split-workspace, 3"
        "$mainMod, 4, split-workspace, 4"
        "$mainMod, 5, split-workspace, 5"
        "$mainMod, 6, split-workspace, 6"
        "$mainMod, 7, split-workspace, 7"
        "$mainMod, 8, split-workspace, 8"
        "$mainMod, 9, split-workspace, 9"
        "$mainMod, 0, split-workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, split-movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, split-movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, split-movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, split-movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, split-movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, split-movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, split-movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, split-movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, split-movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, split-movetoworkspacesilent, 10"

        # full screen
        "$mainMod, F, fullscreen"

        # Hyprshot
        # Screenshot a window
        "$mainMod, PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m window"
        # Screenshot a monitor
        ", PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m output"

        # random bindings
        ",  XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"

        "$mainMod, SPACE, exec, ${pkgs.cliphist}/bin/cliphist list"
        "$mainMod, X, exec, ${pkgs.alacritty}/bin/alacritty --class clipse -e ${pkgs.clipse}/bin/clipse"

        "ALT, Tab, exec, ${snappy-switcher} next"
        "ALT SHIFT, Tab, exec, ${snappy-switcher} prev"
        "$mainMod, L, exec, ${lib.getExe lock_cmd}"

        "$mainMod, code:9, exec, killall hyprland-cursor-lock || ${lib.getExe pkgs.hyprland-cursor-lock}"
      ];

      "$mainMod" = "SUPER";

      binds = {
        drag_threshold = 10;
      };

      bindm = [
        "$mainMod,mouse:272,movewindow"
        "$mainMod ALT, mouse:272, resizewindow"
        "$mainMod,mouse:273,resizewindow"
      ];

      bindl = [
        ", switch:on:Lid Switch, exec, hyprctl dispatch dpms off"
        ", switch:off:Lid Switch, exec, hyprctl dispatch dpms on"
      ];

      monitor = [
        "WAYLAND-1,disabled"
        ",preferred,auto,1"
      ];

      input = {
        follow_mouse = true;
        touchpad = {
          natural_scroll = false;
        };
        touchdevice = {
          enabled = false;
        };
        sensitivity = 0.5;
      };

      general = {
        gaps_in = 2;
        gaps_out = 2;
        border_size = 2;
        layout = "dwindle";
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      decoration = {
        rounding = 7;
        rounding_power = 4;
        active_opacity = 1;
        blur = {
          enabled = false;
          size = 8;
          passes = 3;
          noise = 0.01;
          contrast = 0.9;
          brightness = 0.8;
          popups = true;
        };
        shadow.enabled = false;
      };

      animations = {
        enabled = true;

        bezier = [
          "wind,0.05,0.9,0.1,1.05" # Wind-like curve
          "winIn,0.1,1.1,0.1,1.1" # Smooth in
          "winOut,0.3,-0.3,0,1" # Smooth out with a bounce
          "liner,1,1,1,1" # Linear curve
          "overshot,0.05,0.9,0.1,1.05" # Overshooting effect
          "smoothOut,0.5,0,0.99,0.99" # Smooth out curve
          "smoothIn,0.5,-0.5,0.68,1.5" # Smooth in curve
        ];
        animation = [
          "windows,1,6,wind,slide" # Window animations using wind curve
          "windowsIn,1,5,winIn,slide" # Windows slide in with winIn curve
          "windowsOut,1,3,smoothOut,slide" # Windows slide out with smoothOut curve
          "windowsMove,1,5,wind,slide" # Window movement with wind curve
          "border,1,1,liner" # Border animation using linear curve
          "borderangle,1,180,liner,loop" # Rotating border animations
          "fade,1,3,smoothOut" # Fade animation with smoothOut curve
          "workspaces,1,5,overshot" # Workspace animation with overshooting curve
          "workspacesIn,1,5,winIn,slide" # Slide in
          "workspacesOut,1,5,winOut,slide" # Slide out
        ];
      };

      gestures = {};

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
        vfr = true;
      };

      layerrule = [
        "blur on, ignore_alpha 0, match:namespace notifications"
        "no_anim on, match:namespace selection"
      ];

      env =
        [
          "GDK_BACKEND,wayland"
          "GDK_SCALE,1"
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
        ];

      cursor = {
        no_hardware_cursors = true;
      };

      windowrule = [
        "tag +games, match:class ^(gamescope)$"
        "tag +games, match:class ^(steam_app_d+)$"
        "no_blur on, fullscreen on, match:tag games*"
        "match:class mpv, content none"
      ];

      exec-once = [
        "${pkgs.bat}/bin/bat cache --build"
        "${pkgs.clipse}/bin/clipse -listen"
        "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "${pkgs.systemd}/bin/systemctl --user import-environment --all"
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular"
        "${portalPackage}/libexec/xdg-desktop-portal-hyprland"
        "${pkgs.xorg.xrdb}/bin/xrdb -merge $HOME/.Xresources"
        "${pkgs.writeShellScriptBin "autostart" ''
          systemctl --user --no-block restart autostart.service
        ''}/bin/autostart"
        "${pkgs.sunsetr}/bin/sunsetr"
        "${pkgs.kanshi}/bin/kanshi"
        "${snappy-switcher} --daemon"
      ];

      debug.disable_scale_checks = true;

      xwayland = {
        force_zero_scaling = false;
        enabled = true;
        use_nearest_neighbor = false;
      };
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock --immediate";
        on_lock_cmd = "hyprctl dispatch dpms off";
        on_unlock_cmd = "hyprctl dispatch dpms on";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = lib.getExe lock_cmd;
        }
        {
          timeout = 320;
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
  };

  services.swaync.enable = true;

  services.wpaperd = {
    enable = false;
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
      enable = true;
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
}
