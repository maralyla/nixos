{
  # needs to be the actual path, because sops is loaded before impermanence
  sops.age.sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
  sops.gnupg.sshKeyPaths = [];
}
