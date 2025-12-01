# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{inputs, ...}: let
  genPkgs = system:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
      config = self.nixpkgs-config;
    };
  inherit (inputs) self;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  genConfiguration = _hostname: {
    type,
    hostPlatform,
    username,
    ...
  }: let
    libx = inputs.nixfigs-helpers.libx.${hostPlatform};
  in
    homeManagerConfiguration {
      pkgs = genPkgs hostPlatform;
      modules = [./configs];
      extraSpecialArgs = {
        hostType = type;
        pkgs = genPkgs hostPlatform;
        inherit
          inputs
          username
          self
          libx
          hostPlatform
          ;
      };
    };
in
  inputs.nixpkgs.lib.mapAttrs genConfiguration (
    inputs.nixpkgs.lib.filterAttrs (_: host: host.type == "home-manager") self.hosts
  )
