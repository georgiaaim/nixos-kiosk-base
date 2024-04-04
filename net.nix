{ config, pkgs, lib, ...}: 
{
  # Enable IP forwarding
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  }; 

  networking = {
    firewall = {
      enable = true;
      # SSH, DNS, MQTT, Unifi, Home Assistant, and Unifi respectively
      allowedTCPPorts = [ 22 53 1883 6053 8080 8123 8443 50537 ];

      # DNS, DHCP, MQTT, Unifi, and mDNS respectively
      allowedUDPPorts = [ 53 67 1883 3478 5353 6053 50537 ];

      # Allow forwarding from LAN to WAN
      extraCommands = ''
        iptables -t nat -A POSTROUTING -o enp2s0 -j MASQUERADE
        iptables -A FORWARD -i enp2s0 -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT
        iptables -A FORWARD -i br0 -o enp2s0 -j ACCEPT
      '';
    };

    # Use Cloudflare DNS and local DNS server
    nameservers = [ "192.168.1.1" "1.1.1.1" ];

    bridges = {
      # Define a bridge device for the LAN
      br0 = {
        interfaces = [ "enp3s0" ];
      };
    };

   interfaces = {
      # WAN interface
      enp2s0 = {
        useDHCP = true;
      };

      # Bridge interface for the LAN and virtual machines/containers
      br0 = {
        useDHCP = false;
        ipv4.addresses = [ {
          address = "192.168.1.1";
          prefixLength = 24;
        } ];
      };
    };
  };


  # Sets up DHCP and DNS servers for the LAN
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      interface = "br0";
      dhcp-range = [ "192.168.1.2,192.168.1.254,12h" ];
      domain-needed = false;
      expand-hosts = true;
      bogus-priv = true;
      server = [
        "192.168.1.1"
        "1.1.1.1"
      ];
      dhcp-leasefile="/var/lib/dnsmasq/dnsmasq.leases";
    };

  };


  # Allows local DNS resolution for bridge network
  #   e.g. `homeassistant.local`
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    allowInterfaces = [ "br0" ];
    publish.enable = true;
  };
}
