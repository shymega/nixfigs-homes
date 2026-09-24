[
  {
    output = {
      alias = "WFH_LEFT";
      criteria = "Dell Inc. DELL P2415Q D8VXF0350C4B";
      mode = "3840x2160@60Hz";
      position = "2560,0";
      scale = 1.5;
      status = "enable";
      transform = "normal";
    };
  }
  {
    output = {
      alias = "WFH_RIGHT";
      criteria = "LG Electronics LG Ultra HD 0x0009B7B4";
      mode = "3840x2160@60Hz";
      position = "0,0";
      scale = 1.5;
      status = "enable";
      transform = "normal";
    };
  }
  {
    output = {
      alias = "FLIPGO_TOP";
      criteria = "Invalid Vendor Codename - RTK FlipGo-A1 demoset-1";
      mode = "2256x1504@60Hz";
      position = "0,0";
      scale = 1.5;
      status = "enable";
      transform = "normal";
    };
  }
  {
    output = {
      alias = "FLIPGO_BOTTOM";
      criteria = "Invalid Vendor Codename - RTK FlipGo-A2 demoset-1";
      mode = "2256x1504@60Hz";
      position = "0,0";
      scale = 1.5;
      status = "enable";
      transform = "normal";
    };
  }
  {
    output = {
      alias = "VITURE_PRO_XR_SINGLE";
      criteria = "CVT VITURE 0x88888800";
      mode = "1920x1080@60Hz";
      position = "0,0";
      scale = 1;
      status = "enable";
      transform = "normal";
    };
  }
  {
    output = {
      alias = "GPD_WM2_INTERNAL";
      criteria = "Japan Display Inc. GPD1001H 0x00000001";
      mode = "2560x1600@60Hz";
      position = "0,0";
      scale = 1.5;
      status = "enable";
      transform = "normal";
    };
  }
  {
    output = {
      alias = "CT_LAPTOP_INTERNAL";
      criteria = "Chimei Innolux Corporation 0x143F*";
      mode = "1920x1200@60Hz";
      position = "0,0";
      scale = 1;
      status = "enable";
      transform = "normal";
    };
  }
  {
    output = {
      alias = "DUO_PRIMARY";
      criteria = "Samsung Display Corp. 0x4166 Unknown";
      mode = "2880x1800@60Hz";
      position = "0,0";
      scale = 1.5;
      status = "enable";
      transform = "180";
    };
  }
  {
    output = {
      alias = "DUO_SECONDARY";
      criteria = "Stargate Technology DP 0x01010101";
      mode = "2880x1800@60Hz";
      position = "0,0";
      scale = 1.5;
      status = "enable";
      transform = "normal";
    };
  }
  {
    output = {
      alias = "WFH_OFFICE_STUDY_FHD";
      criteria = "HP Inc. HP E243m 3CQ0290BM5";
      mode = "1920x1080@60Hz";
      position = "0,0";
      scale = 1;
      status = "enable";
      transform = "normal";
    };
  }
  {
    profile = {
      exec = [];
      name = "home_workstation_default";
      outputs = [
        {
          criteria = "Dell Inc. DELL P2415Q D8VXF0350C4B";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "LG Electronics LG Ultra HD 0x0009B7B4";
          mode = "3840x2160@60Hz";
          position = "2560,0";
          scale = 1.5;
          status = "enable";
          transform = "90";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "home_workstation_dual_flipgo";
      outputs = [
        {
          criteria = "Dell Inc. DELL P2415Q D8VXF0350C4B";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "LG Electronics LG Ultra HD 0x0009B7B4";
          mode = "3840x2160@60Hz";
          position = "2560,0";
          scale = 1.5;
          status = "enable";
          transform = "90";
        }
        {
          criteria = "Invalid Vendor Codename - RTK FlipGo-A1 demoset-1";
          mode = "2256x1504@60Hz";
          position = "4000,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Invalid Vendor Codename - RTK FlipGo-A2 demoset-1";
          mode = "2256x1504@60Hz";
          position = "4000,1003";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "home_workstation_viture";
      outputs = [
        {
          criteria = "LG Electronics LG Ultra HD 0x0009B7B4";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "Dell Inc. DELL P2415Q D8VXF0350C4B";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "CVT VITURE 0x88888800";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "home_workstation_single_flipgo_viture";
      outputs = [
        {
          criteria = "Invalid Vendor Codename - RTK FlipGo-A1 demoset-1";
          mode = "2256x1504@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "Dell Inc. DELL P2415Q D8VXF0350C4B";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "Invalid Vendor Codename - RTK FlipGo-A2 demoset-1";
          mode = "2256x1504@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "CVT VITURE 0x88888800";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "ct_laptop_default";
      outputs = [
        {
          criteria = "Chimei Innolux Corporation 0x143F*";
          mode = "1920x1200@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "ct_office_dual_fhd_desk_4093";
      outputs = [
        {
          criteria = "Philips Consumer Electronics Company PHL 243V5 UK01715028251";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "270";
        }
        {
          criteria = "Chimei Innolux Corporation 0x143F*";
          mode = "1920x1200@60Hz";
          position = "462,1920";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Synaptics Inc Non-PnP 0x00BC614E";
          mode = "1920x1080@60Hz";
          position = "1080,840";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "ct_wfh";
      outputs = [
        {
          criteria = "Chimei Innolux Corporation 0x143F*";
          mode = "1920x1200@60Hz";
          position = "0,0";
          scale = 1;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "Dell Inc. DELL P2415Q D8VXF0350C4B";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "LG Electronics LG Ultra HD 0x0009B7B4";
          mode = "3840x2160@60Hz";
          position = "2560,0";
          scale = 1.5;
          status = "enable";
          transform = "90";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "ct_laptop_home_viture";
      outputs = [
        {
          criteria = "Chimei Innolux Corporation 0x143F*";
          mode = "1920x1200@60Hz";
          position = "0,0";
          scale = 1;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "LG Electronics LG Ultra HD 0x0009B7B4";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "CVT VITURE 0x88888800";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "ct_laptop_viture";
      outputs = [
        {
          criteria = "Chimei Innolux Corporation 0x143F*";
          mode = "1920x1200@60Hz";
          position = "0,0";
          scale = 1;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "CVT VITURE 0x88888800";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "duo_builtin_single";
      outputs = [
        {
          criteria = "Samsung Display Corp. 0x4166 Unknown";
          mode = "2880x1800@60Hz";
          position = "0,1200";
          scale = 1.5;
          status = "enable";
          transform = "180";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "duo_builtin_dual";
      outputs = [
        {
          criteria = "Stargate Technology DP 0x01010101";
          mode = "2880x1800@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Samsung Display Corp. 0x4166 Unknown";
          mode = "2880x1800@60Hz";
          position = "0,1200";
          scale = 1.5;
          status = "enable";
          transform = "180";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "duo_builtin_single_wfh_office_default";
      outputs = [
        {
          criteria = "Dell Inc. DELL P2415Q D8VXF0350C4B";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Samsung Display Corp. 0x4166 Unknown";
          mode = "2880x1800@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "180";
        }
        {
          criteria = "LG Electronics LG Ultra HD 0x0009B7B4";
          mode = "3840x2160@60Hz";
          position = "2560,0";
          scale = 1.5;
          status = "enable";
          transform = "90";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "duo_builtin_dual_wfh_office_default";
      outputs = [
        {
          criteria = "Dell Inc. DELL P2415Q D8VXF0350C4B";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Samsung Display Corp. 0x4166 Unknown";
          mode = "2880x1800@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "180";
        }
        {
          criteria = "Stargate Technology DP 0x01010101";
          mode = "2880x1800@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "LG Electronics LG Ultra HD 0x0009B7B4";
          mode = "3840x2160@60Hz";
          position = "2560,0";
          scale = 1.5;
          status = "enable";
          transform = "90";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "duo_builtin_dual_wfh_office_study";
      outputs = [
        {
          criteria = "Stargate Technology DP 0x01010101";
          mode = "2880x1800@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Samsung Display Corp. 0x4166 Unknown";
          mode = "2880x1800@60Hz";
          position = "0,1200";
          scale = 1.5;
          status = "enable";
          transform = "180";
        }
        {
          criteria = "HP Inc. HP E243m 3CQ0290BM5";
          mode = "1920x1080@60Hz";
          position = "1920,650";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "duo_builtin_single_flipgo_left";
      outputs = [
        {
          criteria = "Invalid Vendor Codename - RTK FlipGo-A1 demoset-1";
          mode = "2256x1504@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Invalid Vendor Codename - RTK FlipGo-A2 demoset-1";
          mode = "2256x1504@60Hz";
          position = "0,1003";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Samsung Display Corp. 0x4166 Unknown";
          mode = "2880x1800@60Hz";
          position = "1504,1200";
          scale = 1.5;
          status = "enable";
          transform = "180";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "duo_builtin_dual_flipgo_left";
      outputs = [
        {
          criteria = "Invalid Vendor Codename - RTK FlipGo-A1 demoset-1";
          mode = "2256x1504@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Invalid Vendor Codename - RTK FlipGo-A2 demoset-1";
          mode = "2256x1504@60Hz";
          position = "0,1003";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Stargate Technology DP 0x01010101";
          mode = "2880x1800@60Hz";
          position = "1504,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Samsung Display Corp. 0x4166 Unknown";
          mode = "2880x1800@60Hz";
          position = "1504,1200";
          scale = 1.5;
          status = "enable";
          transform = "180";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "duo_builtin_single_viture";
      outputs = [
        {
          criteria = "Samsung Display Corp. 0x4166 Unknown";
          mode = "2880x1800@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "180";
        }
        {
          criteria = "CVT VITURE 0x88888800";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "duo_builtin_dual_viture";
      outputs = [
        {
          criteria = "Stargate Technology DP 0x01010101";
          mode = "2880x1800@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "Samsung Display Corp. 0x4166 Unknown";
          mode = "2880x1800@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "180";
        }
        {
          criteria = "CVT VITURE 0x88888800";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "duo_builtin_single_home_viture";
      outputs = [
        {
          criteria = "LG Electronics LG Ultra HD 0x0009B7B4";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "Samsung Display Corp. 0x4166 Unknown";
          mode = "2880x1800@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "180";
        }
        {
          criteria = "CVT VITURE 0x88888800";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "duo_office_dual_fhd_desk_4093";
      outputs = [
        {
          criteria = "Philips Consumer Electronics Company PHL 243V5 UK01715028251";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "270";
        }
        {
          criteria = "Samsung Display Corp. 0x4166 Unknown";
          mode = "2880x1800@60Hz";
          position = "462,1920";
          scale = 1.5;
          status = "enable";
          transform = "180";
        }
        {
          criteria = "Synaptics Inc Non-PnP 0x00BC614E";
          mode = "1920x1080@60Hz";
          position = "1080,840";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "gpd_wm2_default";
      outputs = [
        {
          criteria = "Japan Display Inc. GPD1001H 0x00000001";
          mode = "2560x1600@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "gpd_wm2_viture_home";
      outputs = [
        {
          criteria = "Japan Display Inc. GPD1001H 0x00000001";
          mode = "2560x1600@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "Dell Inc. DELL P2415Q D8VXF0350C4B";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "CVT VITURE 0x88888800";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "gpd_wm2_viture";
      outputs = [
        {
          criteria = "Japan Display Inc. GPD1001H 0x00000001";
          mode = "2560x1600@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "CVT VITURE 0x88888800";
          mode = "1920x1080@60Hz";
          position = "0,0";
          scale = 1;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "gpd_wm2_home";
      outputs = [
        {
          criteria = "Dell Inc. DELL P2415Q D8VXF0350C4B";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Japan Display Inc. GPD1001H 0x00000001";
          mode = "2560x1600@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "disable";
          transform = "normal";
        }
        {
          criteria = "LG Electronics LG Ultra HD 0x0009B7B4";
          mode = "3840x2160@60Hz";
          position = "2560,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
  {
    profile = {
      exec = [];
      name = "gpd_wm2_flipgo_left";
      outputs = [
        {
          criteria = "Invalid Vendor Codename - RTK FlipGo-A1 demoset-1";
          mode = "2256x1504@60Hz";
          position = "0,0";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Invalid Vendor Codename - RTK FlipGo-A2 demoset-1";
          mode = "2256x1504@60Hz";
          position = "0,1002";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
        {
          criteria = "Japan Display Inc. GPD1001H 0x00000001";
          mode = "2560x1600@60Hz";
          position = "1504,479";
          scale = 1.5;
          status = "enable";
          transform = "normal";
        }
      ];
    };
  }
]
