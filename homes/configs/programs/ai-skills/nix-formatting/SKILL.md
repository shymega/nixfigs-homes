---
name: nix-formatting
description: Format, lint, and add license headers to Nix files in this repo. Use whenever creating or editing a .nix file here, or before committing Nix changes.
---

# Nix formatting for this repo

- Format with `alejandra <file>` (the repo's chosen formatter, also available as `nixfmt`). Run it on every changed `.nix` file before finishing.
- Lint with `statix check <path>` and fix anything it flags (dead code, obvious anti-patterns) unless there's a good reason not to.
- Every `.nix` file starts with an SPDX header, matching the existing files:

  ```nix
  # SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
  #
  # SPDX-License-Identifier: GPL-3.0-only
  ```

  Check a neighboring file in the same directory for the exact header already in use (some files use only the copyright line, others add the license line) and match it rather than guessing.
- Keep the terse module style already used under `homes/configs/programs/`: a single `{ ... }: { programs.<name> = { enable = true; ... }; }` block, no unnecessary `let`/`with`, no comments explaining what an option does (the option name already says that).
