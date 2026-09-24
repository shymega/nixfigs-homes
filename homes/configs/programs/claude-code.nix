{pkgs, ...}: {
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
    skills = ./ai-skills;
    context = ''
      Keep changes minimal and scoped; don't add abstractions or config beyond
      what's asked. Match the existing style of the surrounding code. Load
      skills as needed rather than restating their content here.

      Prefer simple, effective solutions over clever or general ones. Avoid
      network access unless the task requires it; don't add dependencies,
      fetches, or calls to external services as a side effect of other work.

      Commit as you go: make small, incremental commits for each logical step
      of a task rather than one large commit at the end. Once the task is
      done, rebase and squash the history into logical, composable commits.
    '';
    hooks.check-ai-policy = ''
      #!/usr/bin/env bash
      set -euo pipefail

      input="$(cat)"
      cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
      [ -n "$cwd" ] || cwd="$PWD"

      repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
      [ -n "$repo_root" ] || exit 0

      state_dir="$HOME/.cache/claude-code/ai-policy-checked"
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
        jq -n --arg ctx "This repository ($repo_root) appears to restrict AI/LLM-assisted contributions (matched wording in $hit). Confirm with the user before making AI-assisted changes here." \
          '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
      fi

      exit 0
    '';
    settings = {
      attribution.commit = "Assisted-by: Claude <noreply@anthropic.com>";
      cleanupPeriodDays = 30;
      autoCompactEnabled = true;
      hooks.SessionStart = [
        {
          hooks = [
            {
              type = "command";
              command = "$HOME/.claude/hooks/check-ai-policy";
            }
          ];
        }
      ];
    };
  };
}
