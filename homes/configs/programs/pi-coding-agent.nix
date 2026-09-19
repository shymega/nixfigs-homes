{pkgs, ...}: let
  jsonFormat = pkgs.formats.json {};
in {
  home.file = {
    ".pi/agent/settings.json".source = jsonFormat.generate "pi-coding-agent-settings.json" {
      compaction = {
        enabled = true;
        reserveTokens = 16384;
        keepRecentTokens = 20000;
      };
    };

    ".pi/agent/extensions/check-ai-policy.ts".text = ''
      import type {ExtensionAPI} from "@earendil-works/pi-coding-agent";
      import {execSync} from "node:child_process";
      import {existsSync, mkdirSync, writeFileSync, readFileSync} from "node:fs";
      import {createHash} from "node:crypto";
      import {join} from "node:path";
      import {homedir} from "node:os";

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

      const ATTRIBUTION_REMINDER =
        "When committing via git, add a trailer 'Assisted-by: Pi <noreply@pi.dev>' " +
        "(pi has no built-in commit attribution setting, so this is the only way to get it).";

      export default function (pi: ExtensionAPI) {
        pi.on("session_start", async (event, ctx) => {
          const cwd = ctx.cwd ?? process.cwd();

          let repoRoot: string | undefined;
          try {
            repoRoot = execSync("git rev-parse --show-toplevel", {
              cwd,
              encoding: "utf8",
            }).trim();
          } catch {
            repoRoot = undefined;
          }

          let policyNote = "";
          if (repoRoot) {
            const stateDir = join(homedir(), ".cache", "pi-coding-agent", "ai-policy-checked");
            mkdirSync(stateDir, {recursive: true});
            const marker = join(stateDir, createHash("sha256").update(repoRoot).digest("hex"));

            if (!existsSync(marker)) {
              writeFileSync(marker, "");

              for (const f of CANDIDATES) {
                const p = join(repoRoot, f);
                if (!existsSync(p)) continue;
                if (PATTERN.test(readFileSync(p, "utf8"))) {
                  policyNote =
                    " This repository (" + repoRoot + ") appears to restrict AI/LLM-assisted " +
                    "contributions (matched wording in " + f + "). Confirm with the user before " +
                    "making AI-assisted changes here.";
                  break;
                }
              }
            }
          }

          pi.sendMessage({
            customType: "ai-policy-check",
            content: ATTRIBUTION_REMINDER + policyNote,
            display: true,
          });
        });
      }
    '';
  };
}
