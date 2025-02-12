{lib, ...}: {
  networking.networkmanager.enable = true;
  networking.useDHCP = false;

  services.resolved = {
    enable = true;
    fallbackDns = ["1.1.1.1" "2606:4700:4700::1111,2606:4700:4700::1001"];
  };

  networking.firewall.enable = true;
  networking.nftables.enable = lib.mkDefault true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}
