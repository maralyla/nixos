{ pkgs, ... }:
{
  programs.gpg = {
    enable = true;
    settings = {
      keyserver = "hkp://keys.gnupg.net";
    };
  };

  services.gpg-agent = {
    enable = true;

    defaultCacheTtl = 86400;
    defaultCacheTtlSsh = 86400;
    maxCacheTtl = 86400;
    maxCacheTtlSsh = 86400;
    enableSshSupport = true;
    extraConfig = ''
      pinentry-program ${pkgs.pinentry-qt}/bin/pinentry
    '' + ''
      allow-loopback-pinentry
    '';
  };

}