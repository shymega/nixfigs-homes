{pkgs, ...}: {
  programs.antigravity-cli = {
    enable = true;
    package = pkgs.unstable.antigravity-cli;
    skills = ./ai-skills;
    context.GEMINI = ''
      This is a personal NixOS/home-manager dotfiles repo (nixfigs-homes). Keep
      changes minimal and scoped; don't add abstractions or config beyond what's
      asked. Match the terse style of existing `homes/configs/programs/*.nix`
      files. Load skills as needed rather than restating their content here.

      When committing, add a trailer `Assisted-by: Antigravity <noreply@google.com>`
      (Antigravity CLI has no built-in commit attribution setting, so this is the
      only way to get it).
    '';
    settings = {
      model.compressionThreshold = 0.5;
      hooks.SessionStart = [
        {
          hooks = [
            {
              type = "command";
              command = "$HOME/.gemini/hooks/check-ai-policy";
            }
          ];
        }
      ];
    };
  };

  home.file.".gemini/hooks/check-ai-policy" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      input="$(cat)"
      cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
      [ -n "$cwd" ] || cwd="$PWD"

      repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
      [ -n "$repo_root" ] || exit 0

      state_dir="$HOME/.cache/antigravity-cli/ai-policy-checked"
      mkdir -p "$state_dir"
      marker="$state_dir/$(printf '%s' "$repo_root" | sha256sum | cut -d' ' -f1)"

      [ -e "$marker" ] && exit 0
      touch "$marker"

      pattern='no[[:space:]-]*(ai|llm)\b|artificial[[:space:]]+intelligence.{0,40}(not[[:space:]]+permitted|prohibited|forbidden|disallowed)|ai[[:space:]-]*generated[[:space:]]+code[[:space:]]+is[[:space:]]+not[[:space:]]+permitted|do[[:space:]]+not[[:space:]]+use[[:space:]]+(ai|generative[[:space:]]+ai|llms?)|generative[[:space:]]+ai[[:space:]]+is[[:space:]]+prohibited'

      candidates=(
        CONTRIBUTING.md
        .github/CONTRIBUTING.md
        README.md
        LICENSE
        LICENSE.md
        LICENSE.txt
        AI_POLICY.md
        .ai-policy
      )

      hit=""
      for f in "''${candidates[@]}"; do
        [ -f "$repo_root/$f" ] || continue
        if grep -EiIq "$pattern" "$repo_root/$f" 2>/dev/null; then
          hit="$f"
          break
        fi
      done

      if [ -n "$hit" ]; then
        jq -n --arg msg "This repository ($repo_root) appears to restrict AI/LLM-assisted contributions (matched wording in $hit). Confirm with the user before making AI-assisted changes here." \
          '{systemMessage: $msg}'
      fi

      exit 0
    '';
  };
}
