{
  pkgs,
  lib,
  inputs,
  ...
}: let
  lock_cmd = pkgs.writeShellScriptBin "hyprlock-wrapped" ''
    #!/usr/bin/env bash
    if pidof ${pkgs.hyprlock}/bin/hyprlock > /dev/null; then
      exit 0
    else
      ${pkgs.hyprlock}/bin/hyprlock --immediate &
      sleep 2s
      hyprctl dispatch dpms off
      wait $(jobs -p)
    fi
  '';
in {
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = true;
    xwayland.enable = true;
    settings = {
      bind = [
        "SUPER, Return, exec, alacritty"

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
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Move workspace to monitor
        "$mainMod ALT, left, movecurrentworkspacetomonitor, l"
        "$mainMod ALT, right, movecurrentworkspacetomonitor, r"

        # full screen
        "SUPER, F, fullscreen"

        # Hyprshot
        # Screenshot a window
        "$mainMod, PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m window"
        # Screenshot a monitor
        # "PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m output"
        # Screenshot a region
        "$shiftMod, PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m region"

        # random bindings
        ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"

        "$mainMod, SPACE, exec, ${pkgs.cliphist}/bin/cliphist list"
        "SUPER, X, exec, ${pkgs.alacritty}/bin/alacritty --class clipse -e ${pkgs.clipse}/bin/clipse"

        # Replicate minimising
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod, S, movetoworkspace, +0"
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod, S, movetoworkspace, special:magic"
        "$mainMod, S, togglespecialworkspace, magic"
        "ALT, Tab, cyclenext"
        "ALT, Tab, bringactivetotop"
        "$mainMod, L, exec, ${lib.getExe lock_cmd}"
      ];

      "$mainMod" = "SUPER";

      binds = {
        drag_threshold = 10;
      };

      bindm = [
        "$mainMod,mouse:272,movewindow"
        "$mainMod,mouse:273,resizewindow"
      ];

      monitor = [
        "WAYLAND-1,disabled"
      ];

      input = {
        follow_mouse = 1;
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
        layout = "master";
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      decoration = {
        rounding = 8;

        blur = {
          enabled = false;
          size = 12;
          passes = 5;
          new_optimizations = true;
          xray = false;
        };

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
        };
      };

      # https://github.com/prasanthrangan/hyprdots/blob/47572bbcac007d1d51e9251debb5dad5df4bbbb9/Configs/.config/hypr/animations/animations-diablo-1.conf
      animations = {
        enabled = true;
        bezier = [
          "default, 0.05, 0.9, 0.1, 1.05"
          "wind, 0.05, 0.9, 0.1, 1.05"
          "overshot, 0.13, 0.99, 0.29, 1.08"
          "liner, 1, 1, 1, 1"
          "bounce, 0.4, 0.9, 0.6, 1.0"
          "snappyReturn, 0.4, 0.9, 0.6, 1.0"
          "slideInFromRight, 0.5, 0.0, 0.5, 1.0"
        ];
        animation = [
          "windows, 1, 5,  snappyReturn, slidevert"
          "windowsIn, 1, 5, snappyReturn, slidevert right"
          "windowsOut, 1, 5, snappyReturn, slide"
          "windowsMove, 1, 6, bounce, slide"
          "layersOut, 1, 5, bounce, slidevert right"
          "fadeIn, 1, 10, default"
          "fadeOut, 1, 10, default"
          "fadeSwitch, 1, 10, default"
          "fadeShadow, 1, 10, default"
          "fadeDim, 1, 10, default"
          "fadeLayers, 1, 10, default"
          "workspaces, 1, 7, overshot, slide"
          "border, 1, 50, liner"
          "layers, 1, 4, bounce, slidevert right"
          "borderangle, 1, 30, liner, loop"
        ];
      };

      gestures = {};

      misc = {
        allow_session_lock_restore = true;
        anr_missed_pings = 10;
        disable_autoreload = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = false;
        key_press_enables_dpms = true;
        lockdead_screen_delay = 5000;
        mouse_move_enables_dpms = false;
        vfr = true;
        vrr = 3;
      };

      render = {
        direct_scanout = 2;
      };

      layerrule = [
        "blur,notifications"
        "ignorezero,notifications"
        "noanim,selection"
      ];

      env = [
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
      ];

      cursor = {
        no_hardware_cursors = 1;
      };

      windowrule = [
        "opacity 1.0 0.95, title:^(.*)$"
      ];

      windowrulev2 = [
        "tag +games, class:^(gamescope)$"
        "tag +games, class:^(steam_app_\d+)$"
        "noblur, tag:games*"
        "fullscreen, tag:games*"
      ];

      exec-once = [
        "${pkgs.bat}/bin/bat cache --build"
        "${pkgs.clipse}/bin/clipse -listen"
        "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "${pkgs.systemd}/bin/systemctl --user import-environment --all"
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular"
        "${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland"
        "${pkgs.xorg.xrdb}/bin/xrdb -merge $HOME/.Xresources"
        "${pkgs.writeShellScriptBin "autostart" ''
          systemctl --user --no-block restart autostart.service
        ''}/bin/autostart"
        "${pkgs.unstable.sunsetr}/bin/sunsetr"
        "${pkgs.kanshi}/bin/kanshi"
      ];

      debug.disable_scale_checks = true;

      xwayland = {
        force_zero_scaling = false;
        enabled = true;
        use_nearest_neighbor = false;
      };
    };
  };

  services.hyprpaper = {
    enable = true;
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = lib.getExe lock_cmd;
        before_sleep_cmd = "loginctl lock-session";

        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
  };

  services.swaync.enable = true;
}
