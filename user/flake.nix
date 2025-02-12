# Inspired https://github.com/sherubthakur/dotfiles/tree/89dd7dc0359ee0c84520fa3143f1763c326fc4d6
{
  description = "Home manager flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    mynur.url = "github:Lykos153/nur-packages";
    #mynur.inputs.nixpkgs.follows = "nixpkgs";
    get-flake.url = "github:ursi/get-flake";
    mum-rofi.url = "github:lykos153/mum-rofi";
    toki.url = "github:lykos153/toki";
    krew2nix.url = "github:lykos153/krew2nix";
    krew2nix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    get-flake,
    nur,
    mynur,
    sops-nix,
    ...
  } @ inputs: let
    overlays = [
      nur.overlay
      mynur.overlay
      (
        # Add packages from flake inputs to pkgs
        final: prev: {
          mum-rofi = inputs.mum-rofi.outputs.defaultPackage.${system};
          toki = inputs.toki.outputs.defaultPackage.${system};
          kubectl = inputs.krew2nix.outputs.packages.${system}.kubectl;
        }
      )
    ];
    systemFlake = get-flake ../system;
    system = "x86_64-linux"; # TODO: make config independent of system
    mkConfig = hostname: username: config: let
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
      nixpkgsConfigPath = userpath + "/nixpkgs-config.nix";
      pkgs = import nixpkgs {
        inherit system;
        config =
          if builtins.pathExists nixpkgsConfigPath
          then import nixpkgsConfigPath
          else {};
        overlays = overlays;
      };
    in (
      # inputs.nixpkgs.lib.nameValuePair
      #     (name + "silvio-pc")
      {
        "name" = username;
        "value" = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules =
            [
              sops-nix.homeManagerModule
              inputs.stylix.homeManagerModules.stylix
              ./home.nix
              {
                home = {
                  homeDirectory = config.home;
                  username = username;
                  stateVersion = "22.05";
                };
                booq = {
                  nix-index = {
                    enable = true;
                    nixpkgs-path = "${inputs.nixpkgs}";
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
            ++ userlist
            ++ hostlist;
        };
      }
    );
    # mkHost = hostname: config:
    # (
    # )
  in {
    homeConfigurations = inputs.nixpkgs.lib.mapAttrs' (mkConfig "silvio-pc") systemFlake.outputs.nixosConfigurations.silvio-pc.config.users.users;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
