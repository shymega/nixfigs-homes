{
  pkgs,
  inputs,
  ...
}: let
  sbx = inputs.agent-sandbox.lib.${pkgs.system};

  # Identity ([user] name/email/signingkey) lives in ~/.gitconfig, not the
  # XDG ~/.config/git/config that home-manager otherwise manages.
  gitConfig = ["$HOME/.gitconfig"];

  githubEnv = {
    GITHUB_TOKEN = "$GITHUB_TOKEN";
  };

  githubDomains = {
    "raw.githubusercontent.com" = ["GET" "HEAD"];
    "api.github.com" = ["GET" "HEAD"];
  };
in {
  home.packages = [
    (sbx.mkSandbox {
      pkg = pkgs.claude-code;
      binName = "claude";
      outName = "claude-sandboxed";
      allowedPackages = sbx.commonTools;
      rwDirs = ["$HOME/.claude"];
      roFiles = gitConfig;
      env =
        githubEnv
        // {
          CLAUDE_CODE_OAUTH_TOKEN = "$CLAUDE_CODE_OAUTH_TOKEN";
        };
      allowedDomains =
        {
          "anthropic.com" = "*";
          "claude.com" = "*";
        }
        // githubDomains;
    })

    (sbx.mkSandbox {
      pkg = pkgs.opencode;
      binName = "opencode";
      outName = "opencode-sandboxed";
      allowedPackages = sbx.commonTools;
      rwDirs = [
        "$HOME/.config/opencode"
        "$HOME/.local/share/opencode"
        "$HOME/.local/state/opencode"
        "$HOME/.cache/opencode"
      ];
      roFiles = gitConfig;
      env =
        githubEnv
        // {
          ANTHROPIC_API_KEY = "$ANTHROPIC_API_KEY";
          OPENAI_API_KEY = "$OPENAI_API_KEY";
        };
      allowedDomains =
        {
          "opencode.ai" = "*";
          "models.dev" = ["GET" "HEAD"];
          "anthropic.com" = "*";
          "api.openai.com" = "*";
        }
        // githubDomains;
    })

    # Domains/env verified against upstream gemini-cli docs, since Antigravity
    # CLI shares its engine; not independently confirmed for the Antigravity
    # fork specifically (its binary is `agy`, not `gemini`). Test after login.
    (sbx.mkSandbox {
      pkg = pkgs.unstable.antigravity-cli;
      binName = "agy";
      outName = "antigravity-sandboxed";
      allowedPackages = sbx.commonTools;
      rwDirs = ["$HOME/.gemini"];
      roFiles = gitConfig;
      env =
        githubEnv
        // {
          GEMINI_API_KEY = "$GEMINI_API_KEY";
          # Gemini/Antigravity sandbox themselves too; let this sandbox do the work.
          GEMINI_SANDBOX = "false";
        };
      allowedDomains =
        {
          "generativelanguage.googleapis.com" = "*";
          "cloudcode-pa.googleapis.com" = "*";
          "oauth2.googleapis.com" = "*";
        }
        // githubDomains;
    })

    (sbx.mkSandbox {
      pkg = pkgs.pi-coding-agent;
      binName = "pi";
      outName = "pi-sandboxed";
      allowedPackages = sbx.commonTools;
      rwDirs = ["$HOME/.pi"];
      roFiles = gitConfig;
      env =
        githubEnv
        // {
          GEMINI_API_KEY = "$GEMINI_API_KEY";
          ANTHROPIC_API_KEY = "$ANTHROPIC_API_KEY";
          OPENAI_API_KEY = "$OPENAI_API_KEY";
        };
      allowedDomains =
        {
          "generativelanguage.googleapis.com" = "*";
          "anthropic.com" = "*";
          "api.openai.com" = "*";
          # `pi install` fetches extensions from npm.
          "registry.npmjs.org" = ["GET" "HEAD"];
        }
        // githubDomains;
    })
  ];
}
