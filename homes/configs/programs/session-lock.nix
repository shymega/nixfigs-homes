{pkgs}: let
  # Enumerate every output (sink) node at runtime: device topology varies
  # between machines, so the IDs are never hardcoded.
  sinks = ''
    wpctl status | awk '/Sinks:/{f=1; next} /Sources:/{f=0} f' | sed -nE 's/^[^0-9]*([0-9]+)\..*/\1/p'
  '';
in {
  # Runs when the session locks: freeze wallpaper rotation, pause media and
  # mute every output.
  lockPrep = pkgs.writeShellScriptBin "session-lock-prep" ''
    set -euo pipefail

    systemctl --user stop wpaperd

    playerctl -a pause || true

    for id in $(${sinks}); do
      wpctl set-mute "$id" 1
    done
  '';

  # Reverses lockPrep on unlock: resume wallpaper rotation, media and audio.
  unlockResume = pkgs.writeShellScriptBin "session-unlock-resume" ''
    set -euo pipefail

    systemctl --user start wpaperd

    playerctl -a play || true

    for id in $(${sinks}); do
      wpctl set-mute "$id" 0
    done
  '';
}
