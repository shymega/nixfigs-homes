[
  {
    profile = {
      name = "home_workstation_default";
      outputs = [
        {
          criteria = "$WFH_LEFT";
          mode = null;
          position = "0,0";
          scale = 1.50;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$WFH_RIGHT";
          mode = null;
          position = "2560,0";
          scale = 1.50;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "home_workstation_flipgo_dual_and_flipgo";
      outputs = [
        {
          criteria = "$WFH_LEFT";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.75;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$FLIPGO_BOTTOM";
          mode = "2256x1504@60Hz";
          position = "4388,859";
          scale = 1.75;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$WFH_RIGHT";
          mode = "3840x2160@60Hz";
          position = "2194,0";
          scale = 1.75;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$FLIPGO_TOP";
          mode = "2256x1504@60Hz";
          position = "4388,0";
          scale = 1.75;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "home_workstation_viture";
      outputs = [
        {
          criteria = "$VITURE_PRO_XR_SINGLE";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$WFH_RIGHT";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "home_workstation_dual_and_flipgo_viture";
      outputs = [
        {
          criteria = "$WFH_LEFT";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$FLIPGO_BOTTOM";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$VITURE_PRO_XR_SINGLE";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$FLIPGO_TOP";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "ct_laptop_default";
      outputs = [
        {
          criteria = "$CT_LAPTOP_INTERNAL";
          mode = "1920x1200@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "ct_office_dual_fhd";
      outputs = [
        {
          criteria = "$CT_LAPTOP_INTERNAL";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "'Philips";
          mode = "1920x1080@60Hz";
          position = "1920,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "ct_office_dual_qhd";
      outputs = [
        {
          criteria = "$CT_LAPTOP_INTERNAL";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Iiyama North America PL2792Q 1226242810124";
          mode = "2560x1440@60Hz";
          position = "1280,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Iiyama North America PL2792Q 1226242810131";
          mode = "2560x1440@60Hz";
          position = "3840,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "ct_wfh";
      outputs = [
        {
          criteria = "$WFH_LEFT";
          mode = "3840x2160@30Hz";
          position = "2560,0";
          scale = 1.50;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$CT_LAPTOP_INTERNAL";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$WFH_RIGHT";
          mode = "3840x2160@30Hz";
          position = "0,0";
          scale = 1.50;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "ct_laptop_home_viture";
      outputs = [
        {
          criteria = "$CT_LAPTOP_INTERNAL";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$VITURE_PRO_XR_SINGLE";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$WFH_RIGHT";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "ct_laptop_viture";
      outputs = [
        {
          criteria = "$CT_LAPTOP_INTERNAL";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$VITURE_PRO_XR_SINGLE";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "duo_builtin_single";
      outputs = [
        {
          criteria = "$DUO_PRIMARY";
          mode = "2880x1800@60Hz";
          position = "0,1200";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "duo_builtin_dual";
      outputs = [
        {
          criteria = "$DUO_SECONDARY";
          mode = "2880x1800@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$DUO_PRIMARY";
          mode = "2880x1800@60Hz";
          position = "0,1200";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "duo_builtin_dual_wfh_office_two";
      outputs = [
        {
          criteria = "$DUO_SECONDARY";
          mode = null;
          position = "0,0";
          scale = 1.50;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$WFH_OFFICE_TWO_FHD";
          mode = null;
          position = "1920,650";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$DUO_PRIMARY";
          mode = null;
          position = "0,1200";
          scale = 1.50;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "duo_builtin_dual_flipgo_left";
      outputs = [
        {
          criteria = "$FLIPGO_BOTTOM";
          mode = null;
          position = "0,1003";
          scale = 1.50;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$DUO_SECONDARY";
          mode = null;
          position = "1504,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$DUO_PRIMARY";
          mode = null;
          position = "1504,1200";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$FLIPGO_TOP";
          mode = null;
          position = "0,0";
          scale = 1.50;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "duo_builtin_single_viture";
      outputs = [
        {
          criteria = "$VITURE_PRO_XR_SINGLE";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$DUO_PRIMARY";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "duo_builtin_dual_viture";
      outputs = [
        {
          criteria = "$VITURE_PRO_XR_SINGLE";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$DUO_PRIMARY";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$DUO_SECONDARY";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "duo_builtin_single_home_viture";
      outputs = [
        {
          criteria = "$VITURE_PRO_XR_SINGLE";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$DUO_PRIMARY";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$WFH_RIGHT";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "duo_builtin_dual_home_viture";
      outputs = [
        {
          criteria = "$VITURE_PRO_XR_SINGLE";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$DUO_SECONDARY";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$DUO_PRIMARY";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$WFH_RIGHT";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "gpd_wm2_default";
      outputs = [
        {
          criteria = "$GPD_WM2_INTERNAL";
          mode = "2560x1600@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "gpd_wm2_viture_home";
      outputs = [
        {
          criteria = "$VITURE_PRO_XR_SINGLE";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$GPD_WM2_INTERNAL";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$WFH_RIGHT";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "gpd_wm2_viture";
      outputs = [
        {
          criteria = "$VITURE_PRO_XR_SINGLE";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$GPD_WM2_INTERNAL";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      name = "gpd_wm2_home";
      outputs = [
        {
          criteria = "$WFH_LEFT";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$GPD_WM2_INTERNAL";
          mode = null;
          position = "0,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "$WFH_RIGHT";
          mode = "3840x2160@60Hz";
          position = "2560,0";
          scale = 1.00;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
]
