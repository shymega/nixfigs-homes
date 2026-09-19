_: {
  programs.wezterm = {
    enable = true;
    settings = {
      set_environment_variables = {
        TERM = "xterm-256color";
      };
    };
  };
}
