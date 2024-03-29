{ config, pkgs, lib, ...}: 
{
  networking = {
    useDHCP = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 8080 8443];
      allowedUDPPorts = [ 3478 ];
    };

    bridges = {
      br0 = {
        interfaces = [ "enp3s0" ];
      };
    };

   interfaces = {
      enp2s0 = {
        useDHCP = true;
      };

      br0 = {
        useDHCP = false;
        ipv4.addresses = [ {
          address = "192.168.1.1";
          prefixLength = 24;
        } ];

      };
    };
  };

  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [
          "br0"
        ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      subnet4 = [
        {
          pools = [
            {
              pool = "192.168.1.2 - 192.168.1.253";
            }
          ];
          subnet = "192.168.1.0/24";
        }
      ];
      valid-lifetime = 4000;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    allowInterfaces = [ "br0" ];
    publish.enable = true;
  };
}
