# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, ... }:

{
  systemd = {
    user = {
      services = {
        network-online = {
          Unit = {
            After = [ "network.target" ];
            PartOf = [ "network-online.target" ];
            Description = "Network is Online";
            RefuseManualStart = "true";
          };
          Service = {
            Type = "oneshot";
            RemainAfterExit = "true";
            ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-online-dzr.flag";
            ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-online-dzr.flag";
          };
          Install = {
            WantedBy = [ "network-online.target" ];
          };
        };
        network-mifi = {
          Unit = {
            RefuseManualStart = "true";
            Description = "Network condition helper for MiFi connections";
            PartOf = [ "network-mifi.target" ];
          };
          Service = {
            Type = "oneshot";
            RemainAfterExit = "true";
            ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-mifi-dzr.flag";
            ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-mifi-dzr.flag";
          };
          Install = {
            WantedBy = [ "network-mifi.target" ];
          };
        };
        network-portal = {
          Unit = {
            RefuseManualStart = "true";
            Description = "Network condition helper for captive portals";
            PartOf = [ "network-portal.target" ];
          };
          Service = {
            Type = "oneshot";
            RemainAfterExit = "true";
            ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-portal-dzr.flag";
            ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-portal-dzr.flag";
          };
          Install = {
            WantedBy = [ "network-portal.target" ];
          };
        };
        network-rnet = {
          Unit = {
            RefuseManualStart = "true";
            Description = "Network condition helper for family network";
            PartOf = [ "network-rnet.target" ];
          };
          Service = {
            Type = "oneshot";
            RemainAfterExit = "true";
            ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-rnet-dzr.flag";
            ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-rnet-dzr.flag";
          };
          Install = {
            WantedBy = [ "network-rnet.target" ];
          };
        };
        network-vpn = {
          Unit = {
            RefuseManualStart = "true";
            Description = "Network condition helper for VPN connections";
            PartOf = [ "network-vpn.target" ];
          };
          Service = {
            Type = "oneshot";
            RemainAfterExit = "true";
            ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-vpn-dzr.flag";
            ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-vpn-dzr.flag";
          };
          Install = {
            WantedBy = [ "network-vpn.target" ];
          };
        };
      };
      targets = {
        network-online = {
          Unit = {
            Requires = [ "network-online.service" ];
            Description = "Connected to a network";
          };
        };
        network-mifi = {
          Unit = {
            Description = "Connected to MiFi";
            Requires = [ "network-mifi.service" ];
          };
        };
        network-portal = {
          Unit = {
            Description = "Connected to captive portal";
            Requires = [ "network-portal.service" ];
          };
        };
        network-rnet = {
          Unit = {
            Description = "Connected to family network";
            Requires = [ "network-rnet.service" ];
          };
        };
        network-vpn = {
          Unit = {
            Description = "Connected to a VPN";
            Requires = [ "network-vpn.service" ];
          };
        };
      };
    };
  };
}
