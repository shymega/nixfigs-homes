# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{
  lib,
  pkgs,
  ...
}:
lib.mkIf true {
  programs.rofi = {
    enable = true;
    font = "IBM Plex Mono";
    extraConfig = {
      dpi = 0;
    };
    plugins = with pkgs; [rofi-emoji];
    cycle = true;
    pass.enable = true;
  };
}
