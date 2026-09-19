{pkgs, ...}: {
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    skills = ./ai-skills;
    context = ''
      This is a personal NixOS/home-manager dotfiles repo (nixfigs-homes). Keep
      changes minimal and scoped; don't add abstractions or config beyond what's
      asked. Match the terse style of existing `homes/configs/programs/*.nix`
      files. Load skills as needed rather than restating their content here.

      When committing, add a trailer `Assisted-by: OpenCode <noreply@opencode.ai>`
      (OpenCode has no built-in commit attribution setting, so this is the only
      way to get it).
    '';
    settings = {
      autoshare = false;
      autoupdate = false;
      compaction = {
        auto = true;
        keep.tokens = 15000;
        buffer = 20000;
      };
    };
  };

  xdg.configFile."opencode/plugins/check-ai-policy.js".text = ''
    import { execSync } from "node:child_process";
    import { existsSync, mkdirSync, writeFileSync, readFileSync } from "node:fs";
    import { createHash } from "node:crypto";
    import { join } from "node:path";
    import { homedir } from "node:os";

    const PATTERN =
      /no[\s-]*(ai|llm)\b|artificial\s+intelligence.{0,40}(not\s+permitted|prohibited|forbidden|disallowed)|ai[\s-]*generated\s+code\s+is\s+not\s+permitted|do\s+not\s+use\s+(ai|generative\s+ai|llms?)|generative\s+ai\s+is\s+prohibited/i;

    const CANDIDATES = [
      "CONTRIBUTING.md",
      ".github/CONTRIBUTING.md",
      "README.md",
      "LICENSE",
      "LICENSE.md",
      "LICENSE.txt",
      "AI_POLICY.md",
      ".ai-policy",
    ];

    export const CheckAiPolicy = async ({directory, worktree}) => ({
      event: async ({event}) => {
        if (event.type !== "session.created") return;

        const repoRoot = worktree || directory;
        if (!repoRoot) return;

        let root;
        try {
          root = execSync("git rev-parse --show-toplevel", {
            cwd: repoRoot,
            encoding: "utf8",
          }).trim();
        } catch {
          return;
        }

        const stateDir = join(homedir(), ".cache", "opencode", "ai-policy-checked");
        mkdirSync(stateDir, {recursive: true});
        const marker = join(stateDir, createHash("sha256").update(root).digest("hex"));
        if (existsSync(marker)) return;
        writeFileSync(marker, "");

        for (const f of CANDIDATES) {
          const p = join(root, f);
          if (!existsSync(p)) continue;
          if (PATTERN.test(readFileSync(p, "utf8"))) {
            console.warn(
              "This repository (" + root + ") appears to restrict AI/LLM-assisted " +
                "contributions (matched wording in " + f + "). Confirm with the user " +
                "before making AI-assisted changes here."
            );
            break;
          }
        }
      },
    });
  '';
}
