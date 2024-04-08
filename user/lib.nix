{
  home-manager,
  nixpkgs,
}: rec {
  mkMinConfig = {
    username,
    hostname,
    genOverlays,
    extraModules,
    extraArgs,
  }: let
    userpath = ./users + "/${username}";
    hostpath = userpath + "/${hostname}";

    userlist =
      if builtins.pathExists userpath
      then [userpath]
      else [];
    hostlist =
      if builtins.pathExists hostpath
      then [hostpath]
      else [];
  in
    home-manager.lib.homeManagerConfiguration ({
        modules =
          [
            ./home.nix
            {
              home = {
                stateVersion = "22.05";
              };
              booq = {
                nix-index = {
                  enable = true;
                  nixpkgs-path = "${nixpkgs}";
                };
              };
            }
            {
              home.sessionVariables.NIX_PATH = "nixpkgs=${nixpkgs}";
              # workaround because the above doesnt seem to work in xorg https://github.com/nix-community/home-manager/issues/1011#issuecomment-1365065753
              programs.zsh.initExtra = ''
                export NIX_PATH="nixpkgs=${nixpkgs}"
              '';
            }
          ]
          ++ extraModules
          ++ userlist
          ++ hostlist;
      }
      // extraArgs);

  mkConfig = {
    genOverlays,
    extraModules,
    hostConfig,
    userConfig,
  }: let
    username = userConfig.name;
    hostname = hostConfig.config.system.name;
  in
    mkMinConfig {
      inherit genOverlays username hostname;
      extraArgs = {
        pkgs = import nixpkgs rec {
          system = hostConfig.pkgs.stdenv.hostPlatform.system;
          overlays = genOverlays system;
        };
      };
      extraModules =
        extraModules
        ++ [
          {
            home = {
              homeDirectory = userConfig.home;
              username = username;
            };
          }
        ];
    };

  mkConfigs = {
    nixosConfigurations,
    modules,
    genOverlays,
  }: let
    f = acc: hostname: hostConfig: let
      users = nixpkgs.lib.attrsets.filterAttrs (_: v: v.isNormalUser) hostConfig.config.users.users;
    in
      acc
      // nixpkgs.lib.mapAttrs' (user: userConfig: {
        name = "${user}@${hostname}";
        value = mkConfig {
          inherit hostConfig userConfig genOverlays;
          extraModules = modules;
        };
      })
      users;
  in
    nixpkgs.lib.attrsets.foldlAttrs f {} nixosConfigurations;
}
