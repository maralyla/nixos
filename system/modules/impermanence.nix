{
  lib,
  config,
  ...
}: let
  cfg = config.booq.impermanence;
in {
  options.booq.impermanence.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };
  config = lib.mkIf cfg.enable {
    # some more paths maybe: https://www.reddit.com/r/NixOS/comments/ymq9s2/comment/iv6cl56/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    environment.persistence."/persist" = {
      hideMounts = true;
      directories =
        [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
        ]
        ++ lib.optional config.hardware.bluetooth.enable "/var/lib/bluetooth"
        ++ lib.optional config.networking.networkmanager.enable "/etc/NetworkManager/system-connections"
        ++ lib.optional config.virtualisation.libvirtd.enable "/var/lib/libvirt"
        ++ lib.optional config.virtualisation.docker.enable "/var/lib/docker";
      files =
        [
          "/etc/machine-id"
          "/root/.zsh_history"
          # { file = "/etc/shadow"; parentDirectory = { group = "shadow"; mode = "u=rw,g=r,o="; }; }
        ]
        ++ lib.optionals config.services.openssh.enable [
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
    };
    users.mutableUsers = false;
  };
}
