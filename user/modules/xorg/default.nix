{
  config,
  lib,
  nixosConfig,
  pkgs,
  ...
}: {
  options.booq.gui.xorg.enable = lib.mkEnableOption "xorg";
  config = lib.mkIf (config.booq.gui.enable && config.booq.gui.xorg.enable) {
    xsession.enable = true;

    home.packages = with pkgs; [
      arandr
      autorandr
      xclip
    ];
    home.file.".xinitrc".source = ./xinitrc;

    # Start on tty1
    programs.zsh.initExtra =
      /*
      sh
      */
      ''
        if [[ $(tty) = /dev/tty1 ]]; then
            unset __HM_SESS_VARS_SOURCED __NIXOS_SET_ENVIRONMENT_DONE # otherwise sessionVariables are not updated
            exec systemd-cat -t startx startx
        fi
      '';
    programs.nushell.extraConfig = ''
      if (tty) == "/dev/tty1" {
          exec systemd-cat -t startx startx
      }
    '';

    services.betterlockscreen = {
      enable = true;
      inactiveInterval = 30;
    };

    programs.rofi = {
      enable = true;
      terminal = "${pkgs.alacritty}/bin/alacritty";
      theme = lib.mkDefault (pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/davatorium/rofi/next/themes/arthur.rasi";
          sha256 = "sha256-2wlR+UURxmk9KvSYm/PmwNKDPC/GV0HcQEH7xDW53k0=";
        }
        + ""); #TODO: How to properly convert the set to a string or path?
    };

    services.dunst = {
      enable = true;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome3.adwaita-icon-theme;
        size = "16x16";
      };
      settings = {
        global = {
          monitor = 0;
          geometry = "600x50-50+65";
          shrink = "yes";
          transparency = 10;
          padding = 16;
          horizontal_padding = 16;
          # font = "JetBrainsMono Nerd Font 10";
          line_height = 4;
          format = ''<b>%s</b>\n%b'';
        };
      };
    };

    services.picom = {
      enable = true;
      activeOpacity = 0.95;
      inactiveOpacity = 0.8;
      #backend = "glx"; # makes cursor flicker on thinkpad. maybe find proper driver?
      fade = true;
      fadeDelta = 5;
      opacityRules = [
        "100:name *= 'i3lock'"
        "100:name *= 'firefox'"
        "100:name *= 'vlc'"
      ];
      shadow = true;
      shadowOpacity = 0.75;
    };

    services.clipmenu.enable = true;
    services.caffeine.enable = true;
  };
}
