{
  config,
  lib,
  nixosConfig,
  pkgs,
  ...
}: let
  laptop = "00ffffffffffff0006af3d1000000000001a0104951f117802c32592575a942a22505400000001010101010101010101010101010101143780b2703828403064310035ad100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343048414b30312e30200a00bd";
  samsung_syncmaster = "00ffffffffffff004c2d87053736535a17150103803420782aee91a3544c99260f5054230800a9408180814081009500b30001010101283c80a070b023403020360006442100001a000000fd00323f1e5111000a202020202020000000fc0053796e634d61737465720a2020000000ff00484d42423630323436320a202001ba02010400023a801871382d40582c450006442100001e023a80d072382d40102c458006442100001e011d007251d01e206e28550006442100001e011d00bc52d01e20b828554006442100001e8c0ad090204031200c4055000644210000188c0ad08a20e02d10103e960006442100001800000000000000000000000000000096";
  benq = "00ffffffffffff0009d1a77845540000171b010380351e782eba45a159559d280d5054a56b80810081c08180a9c0b300d1c001010101023a801871382d40582c4500132a2100001e000000ff0037364830353939363031390a20000000fd00324c1e5311000a202020202020000000fc0042656e5120474c32343530480a014f020322f14f90050403020111121314060715161f2309070765030c00100083010000023a801871382d40582c4500132a2100001f011d8018711c1620582c2500132a2100009f011d007251d01e206e285500132a2100001e8c0ad08a20e02d10103e9600132a21000018000000000000000000000000000000000000000000eb";
  work00 = "00ffffffffffff00226700000000000035190103803c22782a3581a656489a24125054afcf008100814081809500a940b30001010101023a801871382d40582c4500dd0c1100001e2f2640a060841a3030203500bbf91000001c000000fd00384c1f5311000a202020202020000000fc00484c3237344850420a202020200154020324f14f900504030207061f1413121116150123097f078301000067030c0010000021023a801871382d40582c450009252100001e011d8018711c1620582c250009252100009e011d007251d01e206e28550009252100001e023a80d072382d40102c458009252100001e00000000000000000000000000000000000000f3";
  work01 = "00ffffffffffff000469a327ae930100101c0104a53c22783aa595aa544fa1260a5054b7ef00d1c0b300950081808140810081c0714f565e00a0a0a029503020350055502100001a000000ff004a344c4d54463130333334320a000000fd00184c18631e04110140f838f03c000000fc00415355532050423237380a2020010d020322714f0102031112130414051f900e0f1d1e2309170783010000656e0c0010008c0ad08a20e02d10103e9600555021000018011d007251d01e206e28550055502100001e011d00bc52d01e20b828554055502100001e8c0ad090204031200c40550055502100001800000000000000000000000000000000000000000096";
  work11 = "00ffffffffffff000469a3278e330100141c0103803c22782aa595aa544fa1260a5054b7ef00d1c0b300950081808140810081c0714f565e00a0a0a029503020350055502100001a000000ff004a354c4d54463037383733340a000000fd00184c186321000a202020202020000000fc00415355532050423237380a2020019302032571520102031112130414050e0f1d1e1f90202122230917078301000065030c0010008c0ad08a20e02d10103e9600555021000018011d007251d01e206e28550055502100001e011d00bc52d01e20b828554055502100001e8c0ad090204031200c40550055502100001800000000000000000000000000000000000098";

  invert = x: 1 / x;
  scale_to_transform = x: [
    [(invert x) 0.0 0.0]
    [0.0 (invert x) 0.0]
    [0.0 0.0 1.0]
  ];
  home-kvm = {
    kvm ? true,
    laptop ? false,
  }: {
    # autorandr has to be invoced with --match-edid for this to work on both devices
    eDP-1 = lib.mkIf laptop {
      enable = true;
      mode = "1920x1080";
      position = "720x1200";
      rate = "60.01";
      transform = scale_to_transform 1.6;
      rotate = "normal";
    };
    DP-2-1 = lib.mkIf kvm {
      enable = true;
      mode = "1920x1200";
      position = "0x0";
      rate = "59.95";
      rotate = "normal";
    };
    DP-2-2 = {
      enable = kvm;
      primary = true;
      mode = "1920x1080";
      position = "1920x0";
      rate = "59.95";
      rotate = "left";
    };
  };
in
  lib.mkIf (config.booq.gui.enable && config.booq.gui.xorg.enable) {
    programs.autorandr = {
      enable = true;
      profiles = {
        ch-home = {
          fingerprint = {
            DP-2-1 = samsung_syncmaster;
            DP-2-2 = benq;
            eDP-1 = laptop;
          };
          config = home-kvm {
            laptop = true;
            kvm = true;
          };
        };
        ch-home-no-kvm = {
          fingerprint = {
            DP-2-2 = benq;
            eDP-1 = laptop;
          };
          config = home-kvm {
            laptop = true;
            kvm = false;
          };
        };
        pc-home = {
          fingerprint = {
            DP-2-1 = samsung_syncmaster;
            DP-2-2 = benq;
          };
          config = home-kvm {
            laptop = false;
            kvm = true;
          };
        };
        pc-home-no-kvm = {
          fingerprint = {
            DP-2-2 = benq;
          };
          config = home-kvm {
            laptop = false;
            kvm = false;
          };
        };
        mobile = {
          fingerprint = {
            eDP-1 = laptop;
          };
          config = {
            eDP-1 = {
              enable = true;
              mode = "1920x1080";
              position = "0x0";
              rate = "60.01";
            };
          };
        };
        cah00 = {
          fingerprint = {
            DP-2-1 = work00;
            eDP-1 = laptop;
          };
          config = {
            eDP-1 = {
              enable = true;
              mode = "1920x1080";
              position = "0x0";
              rate = "60.01";
            };
            DP-2-1 = {
              enable = true;
              primary = true;
              mode = "1920x1080";
              position = "1920x0";
              rate = "60.00";
            };
          };
        };
        cah01 = {
          fingerprint = {
            DP-2-2 = work01;
            eDP-1 = laptop;
          };
          config = {
            eDP-1 = {
              enable = true;
              mode = "1920x1080";
              position = "2560x595";
              rate = "60.01";
            };
            DP-2-2 = {
              enable = true;
              primary = true;
              mode = "2560x1440";
              position = "0x0";
              rate = "59.95";
            };
          };
        };
        cah11 = {
          fingerprint = {
            DP-1-2 = work11;
            eDP-1 = laptop;
          };
          config = {
            eDP-1 = {
              enable = true;
              mode = "1920x1080";
              position = "2560x689";
              rate = "60.01";
            };
            DP-1-2 = {
              enable = true;
              primary = true;
              mode = "2560x1440";
              position = "0x0";
              rate = "59.95";
            };
          };
        };
      };
    };
  }
