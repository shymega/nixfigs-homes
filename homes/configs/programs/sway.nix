{
  pkgs,
  config,
  lib,
  ...
} @ args: let
  windowManager = args.osConfig.nixfigs.graphical.windowManagers.selectedWindowManager or "hyprland";
  lockScripts = import ./session-lock.nix {inherit pkgs;};
  lockPrep = lib.getExe lockScripts.lockPrep;
  unlockResume = lib.getExe lockScripts.unlockResume;
  swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";
in {
  wayland.windowManager.sway = let
    modifier = "Mod4";
    terminal = "alacritty";
    menu = "wm-menu";

    toWorkspaceKey = n:
      if n == 10
      then "0"
      else toString n;

    workspaceBindings = lib.listToAttrs (
      lib.concatMap (i: let
        key = toWorkspaceKey i;
      in [
        {
          name = "${modifier}+${key}";
          value = "workspace number ${toString i}";
        }
        {
          name = "${modifier}+Shift+${key}";
          value = "move container to workspace number ${toString i}";
        }
      ]) (lib.range 1 10)
    );
  in {
    enable = windowManager == "sway";
    config = {
      inherit modifier terminal menu;
      bars = [];
      input."*" = {
        xkb_layout = "us,gb";
        xkb_options = "grp:alt_shift_toggle";
        repeat_delay = "300";
        repeat_rate = "30";
      };
      keybindings = lib.mkForce (
        workspaceBindings
        // {
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+q" = "kill";
          "${modifier}+l" = "exec loginctl lock-session";
          "${modifier}+p" = "exec ${menu}";
          "${modifier}+Shift+q" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
          "${modifier}+Shift+y" = "reload";

          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          "${modifier}+Ctrl+Left" = "move left";
          "${modifier}+Ctrl+Down" = "move down";
          "${modifier}+Ctrl+Up" = "move up";
          "${modifier}+Ctrl+Right" = "move right";

          "${modifier}+Shift+Left" = "move container to output left";
          "${modifier}+Shift+Down" = "move container to output down";
          "${modifier}+Shift+Up" = "move container to output up";
          "${modifier}+Shift+Right" = "move container to output right";

          "${modifier}+v" = "floating toggle";
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+a" = "focus parent";
          "${modifier}+space" = "focus mode_toggle";

          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";

          "${modifier}+r" = "mode resize";

          "${modifier}+Escape" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0";

          "${modifier}+Alt+t" = "mode passthrough";
          "${modifier}+Shift+p" = "mode present";

          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";
        }
      );
      modes = lib.mkForce {
        resize = {
          "Left" = "resize shrink width 10px";
          "Down" = "resize grow height 10px";
          "Up" = "resize shrink height 10px";
          "Right" = "resize grow width 10px";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
        passthrough = {
          "${modifier}+Alt+t" = "mode default";
        };
        present = {
          m = "mode default; exec wl-present mirror";
          o = "mode default; exec wl-present set-output";
          r = "mode default; exec wl-present set-region";
          "Shift+r" = "mode default; exec wl-present unset-region";
          s = "mode default; exec wl-present set-scaling";
          f = "mode default; exec wl-present toggle-freeze";
          c = "mode default; exec wl-present custom";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };
      startup = [
        {
          command = "wl-paste -t text --watch clipman store";
        }
      ];
    };
    extraConfig = ''
      bindsym --locked XF86AudioPlay exec playerctl play-pause
      bindsym --release Mod4+Escape exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1
    '';
  };

  services.swayidle = let
    swaylock = lib.getExe pkgs.swaylock;
  in {
    enable = config.wayland.windowManager.sway.enable;
    systemdTargets = ["sway-session.target"];
    timeouts = [
      {
        timeout = 300;
        command = "${swaylock} -f -c 000000";
      }
      {
        timeout = 302;
        command = "swaymsg \"output * power off\"";
        resumeCommand = "swaymsg \"output * power on\"";
      }
    ];
    events = {
      "before-sleep" = "${lockPrep} && ${swaync-client} -dn && ${swaylock} -f -c 000000 && sleep 2s && swaymsg \"output * power off\"";
      lock = "${lockPrep} && ${swaync-client} -dn && ${swaylock} -f -c 000000 && sleep 2s && swaymsg \"output * power off\"";
      "after-resume" = "${unlockResume} && ${swaync-client} -df && swaymsg \"output * power on\"";
      unlock = "${unlockResume} && ${swaync-client} -df && swaymsg \"output * power on\"";
    };
  };

  home.packages = lib.mkIf config.wayland.windowManager.sway.enable (with pkgs; [
    swaylock
    wl-clipboard
    clipman
    wl-mirror
  ]);
}
