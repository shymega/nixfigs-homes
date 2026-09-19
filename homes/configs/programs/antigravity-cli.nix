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
    '';
  };
}
