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
    '';
    settings = {
      autoshare = false;
      autoupdate = false;
    };
  };
}
