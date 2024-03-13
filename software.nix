{pkgs, ...}: 
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
     "radio_browser"
    ];
    config = {
      # Includes dependencies for a basic setup
     # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
    };
  };

  environment.systemPackages = with pkgs; [
    parted
  ];

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
