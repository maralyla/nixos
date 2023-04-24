{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-master.url = "github:nixos/nixpkgs/master";
  outputs = { self, nixpkgs, nixpkgs-master }:
  let
    #machinedir = ./machines
    lib = nixpkgs.lib;
    mkHost = name: lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
          {
           options.booq.audio = lib.mkOption {
            default = "pulseaudio";
            type = lib.types.str;
           };
          }
          ./configuration.nix
          (./machines + "/${name}")
          {
            networking.hostName = name;
            nix.registry.nixpkgs.flake = nixpkgs; # Pin flakes so search, shell etc. are faster. From https://ianthehenry.com/posts/how-to-learn-nix/more-flakes/
            nix.registry.nixpkgs-master.flake = nixpkgs-master;
          }
      ];
    };
  in
  {
      nixosConfigurations = builtins.mapAttrs (name: _: mkHost name) (builtins.readDir ./machines);
  };
}
