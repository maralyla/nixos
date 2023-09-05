{ config, lib, nixosConfig, pkgs, ... }:
{
  imports = map (n: "${./modules}/${n}") (builtins.attrNames (builtins.readDir ./modules));

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.password-store.enable = true;
  services.pass-secret-service = {
    enable = true;
    storePath = config.programs.password-store.settings.PASSWORD_STORE_DIR;
  };

  programs.bat = {
    enable = true;
    config = {
      tabs = "4";
    };
  };

  home.packages = with pkgs; [
    vifm
    htop
    pwgen
    git
    git-absorb
    git-remote-gcrypt
    git-annex
    git-annex-remote-googledrive
    tig
    gitui
    tea
    glab
    gh
    jq
    yq
    mr
    lykos153.garden
    ripgrep
    ripgrep-all # search in docs, pdfs etc.
    fd # simpler find
    ncdu
    python3Packages.ipython
    screen
    pv
    unzip
    moreutils
    tldr
    lsd # new ls
    sd # new sed
    profanity

    poetry
    just

    lykos153.shrinkpdf
    lykos153.git-rstash
    lykos153.cb
    feh
  ];

}
