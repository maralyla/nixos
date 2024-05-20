{
  config,
  lib,
  pkgs,
  ...
}: let
  okular-x11 = pkgs.symlinkJoin {
    name = "okular";
    paths = [pkgs.okular];
    buildInputs = [pkgs.makeWrapper];
    # force okular to use xwayland, because of https://github.com/swaywm/sway/issues/4973
    postBuild = ''
      wrapProgram $out/bin/okular \
        --set QT_QPA_PLATFORM xcb
    '';
  };
in {
  options.booq.gui.enable = lib.mkEnableOption "gui";
  config = lib.mkIf config.booq.gui.enable {
    programs = {
      chromium.enable = true;
    };

    home.packages = with pkgs; [
      termite
      gajim
      thunderbird
      element-desktop
      fractal
      pavucontrol
      libreoffice
      nomacs
      okular-x11
      xfce.thunar
      vlc
      system-config-printer
      wireshark
      lykos153.cb
      feh
    ];

    gtk = {
      enable = true;
      theme = lib.mkDefault {
        name = "Materia-dark";
        package = pkgs.materia-theme;
      };
      iconTheme = {
        name = "Numix";
        package = pkgs.numix-icon-theme;
      };
    };

    services = {
      udiskie.enable = true;
      blueman-applet.enable = true;
      pasystray.enable = true;
    };

    home.sessionVariables = lib.mkIf config.booq.gui.sway.enable {
      # MOZ_ENABLE_WAYLAND = "1"; not yet, because of https://github.com/swaywm/wlroots/issues/3189
    };
  };
}
