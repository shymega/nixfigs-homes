---
name: commit-style
description: Write commit messages and PR descriptions matching this repo's Conventional Commits history. Use whenever proposing or creating a git commit in this repo.
---

# Commit style for this repo

This repo uses Conventional Commits, scoped to the affected module or program. Match the existing history exactly:

- `feat(stylix): enable release-version mismatch check`
- `fix(hyprlock): stop watchdog/lock_cmd from racing duplicate launches`
- `fix(waybar): don't enable waybar under KDE`
- `chore: Update Flake inputs`
- `refactor: source Hyprland via nixfigs-pkgs/hyprnix`

Rules:
- Type is one of `feat`, `fix`, `chore`, `refactor` (others like `docs`, `test` only if they clearly fit).
- Scope is the program/module touched (e.g. `hyprlock`, `waybar`, `stylix`, `alacritty`), lowercase, in parens — omit the scope only for repo-wide changes like flake input bumps.
- Summary is imperative, lowercase after the colon, no trailing period, short (fits on one line).
- Don't add a body unless the change needs explanation beyond the diff — most commits in this repo are a single line.
- Never add a commit body/footer unless asked; this repo's `home.stateVersion`-style terseness applies to commit messages too.
