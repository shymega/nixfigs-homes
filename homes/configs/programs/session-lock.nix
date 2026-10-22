{pkgs}: let
  systemctl = "${pkgs.systemd}/bin/systemctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  pidof = "${pkgs.procps}/bin/pidof";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";

  # Enumerate every output (sink) node at runtime: device topology varies
  # between machines, so the IDs are never hardcoded.
  sinks = ''
    ${wpctl} status | awk '/Sinks:/{f=1; next} /Sources:/{f=0} f' | sed -nE 's/^[^0-9]*([0-9]+)\..*/\1/p'
  '';
in {
  # Runs when the session locks: freeze wallpaper rotation, pause media and
  # mute every output.
  lockPrep = pkgs.writeShellScriptBin "session-lock-prep" ''
    set -euo pipefail

    ${systemctl} --user stop wpaperd

    ${playerctl} -a pause || true

    for id in $(${sinks}); do
      ${wpctl} set-mute "$id" 1
    done
  '';

  # Reverses lockPrep on unlock: resume wallpaper rotation, media and audio.
  unlockResume = pkgs.writeShellScriptBin "session-unlock-resume" ''
    set -euo pipefail

    ${systemctl} --user start wpaperd

    for id in $(${sinks}); do
      ${wpctl} set-mute "$id" 0
    done
  '';

  # Reports (via exit status) whether the most recent resume-from-suspend was
  # triggered by one of the unattended RTC wake timers -- alarm-clock.timer
  # on nixfigs-public, scheduled-wake.timer on nixfigs-work -- rather than a
  # real user interaction (lid open, keypress). The idle daemons' resume
  # hooks use this to decide whether the display should be turned back on at
  # all: an unattended wake has nobody there to look at it, so forcing DPMS
  # on just leaves the screen lit until the next idle cycle catches up.
  wasScheduledWake = pkgs.writeShellScriptBin "was-scheduled-wake" ''
    set -euo pipefail

    now=$(date +%s)

    for unit in alarm-clock.timer scheduled-wake.timer; do
      last=$(${systemctl} show "$unit" -p LastTriggerUSec --value 2>/dev/null) || continue
      if [ -z "$last" ] || [ "$last" = "n/a" ]; then
        continue
      fi

      last_epoch=$(date -d "$last" +%s 2>/dev/null) || continue
      diff=$(( now - last_epoch ))

      # The resume hook runs within a second or two of wake, so a timer that
      # last fired in roughly that window is what woke the machine.
      if [ "$diff" -ge 0 ] && [ "$diff" -le 15 ]; then
        exit 0
      fi
    done

    exit 1
  '';

  # `before_sleep_cmd` runs synchronously while hypridle holds the sleep
  # delay-inhibitor, so actual suspend can't proceed until this returns --
  # but it previously just fired `loginctl lock-session` and returned
  # immediately, with both the lock request and hyprlock's own startup
  # happening asynchronously after that. That let suspend proceed before
  # hyprlock had even started, so on resume it raced ext-session-lock-v1's
  # own lock-frame timeout (misc:lockdead_screen_delay) instead of having a
  # lock surface ready, flashing Hyprland's "lockdead" screen
  # (hyprwm/hyprlock#991). Waiting here (bounded, so a hyprlock that never
  # starts can't block suspend forever) keeps the inhibitor held long enough
  # for it to actually be running first.
  lockAndWait = pkgs.writeShellScriptBin "session-lock-and-wait" ''
    set -euo pipefail

    ${loginctl} lock-session

    for _ in $(seq 1 30); do
      ${pidof} hyprlock >/dev/null 2>&1 && exit 0
      sleep 0.1
    done
  '';
}
