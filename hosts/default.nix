# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, ... }:
let
  inherit (inputs.nixpkgs.lib.strings) hasSuffix;
  mkHost =
    {
      type ? "nixos",
      hostname ? null,
      hostPlatform ? "x86_64-linux",
      username ? "dzrodriguez",
      hostRoles ? [ "workstation" ],
      pubkey ? null,
      deployable ? false,
    }:
    if type == "home-manager" then
      assert ((hasSuffix "linux" hostPlatform) || (hasSuffix "darwin" hostPlatform) && hostname == null);
      assert pubkey == null;
      {
        inherit
          deployable
          hostPlatform
          hostRoles
          hostname
          type
          username
          ;
      }
    else
      throw "unknown host type '${type}'";
in
{
  "dzrodriguez@x86_64-linux" = mkHost {
    type = "home-manager";
    username = "dzrodriguez";
    hostPlatform = "x86_64-linux";
  };

  "dzrodriguez@aarch64-linux" = mkHost {
    type = "home-manager";
    username = "dzrodriguez";
    hostPlatform = "aarch64-linux";
  };
}
